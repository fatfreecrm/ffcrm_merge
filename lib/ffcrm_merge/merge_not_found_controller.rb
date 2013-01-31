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

%w(AccountsController ContactsController).each do |controller|
  controller.classify.constantize.class_eval do

    private

    #
    #----------------------------------------------------------------------------
    # If contacts/1 is merged into contacts/2 then GET contacts/1 redirects to GET contacts/2
    def respond_to_not_found_with_merged(*types)
      alias_klass = "#{klass}Alias".constantize   # AccountAlias
      entity_method = "#{klass.to_s.downcase}_id" # account_id
      finder = :"destroyed_#{entity_method}"      # destroyed_account_id
      if record = alias_klass.where(finder => params[:id]).limit(1).first
        redirect_to :id => record.send(entity_method)
      else
        respond_to_not_found_without_merged
      end
    end
    alias_method_chain :respond_to_not_found, :merged

  end

end
