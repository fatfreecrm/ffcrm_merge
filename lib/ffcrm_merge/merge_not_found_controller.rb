# Fat Free CRM
# Copyright (C) 2008-2010 by Michael Dvorkin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#------------------------------------------------------------------------------

ActiveSupport.on_load(:action_controller) do
  [AccountsController, ContactsController].each do |controller|
    controller.class_eval do

      rescue_from ActiveRecord::RecordNotFound, with: :respond_to_not_found_with_merged

      private
      #
      #----------------------------------------------------------------------------
      # If contacts/1 is merged into contacts/2 then GET contacts/1 redirects to GET contacts/2
      def respond_to_not_found_with_merged
        klass_name = controller_name.classify
        alias_klass = "#{klass_name}Alias".constantize   # AccountAlias
        entity_method = "#{klass_name.downcase}_id" # account_id
        finder = :"destroyed_#{entity_method}"      # destroyed_account_id
        if record = alias_klass.where(finder => params[:id]).limit(1).first
          redirect_to id: record.send(entity_method)
        else
          # copied from ApplicationController#respond_to_not_found
          flash[:warning] = t(:msg_asset_not_available, klass_name)
          respond_to do |format|
            format.html { redirect_to(action: :index) }
            format.js   { render text: 'window.location.reload();' }
            format.json { render text: flash[:warning],  status: :not_found }
            format.xml  { render xml: [flash[:warning]], status: :not_found }
          end
        end
      end
    end
  end
end
