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

module FfcrmMerge
  module RedirectToMergedRecord

    extend ActiveSupport::Concern
 
    included do
      rescue_from ActiveRecord::RecordNotFound, with: :respond_to_not_found
    end

    private
    #
    #----------------------------------------------------------------------------
    # If accounts/1 is merged into accounts/2 then GET accounts/1 redirects to GET accounts/2
    def respond_to_not_found(*types)
      klass = controller_name.classify.constantize
      alias_klass = "#{klass}Alias".constantize   # e.g. AccountAlias
      entity_method = "#{klass.to_s.downcase}_id" # e.g. account_id
      finder = "destroyed_#{entity_method}"       # e.g. destroyed_account_id
      if record = alias_klass.where(finder => params[:id]).limit(1).first
        redirect_to id: record.send(entity_method)
      else
        raise *types
      end
    end

  end
end
