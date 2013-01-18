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

AccountsController.class_eval do

  private

  #----------------------------------------------------------------------------
  def respond_to_not_found_with_merged(*types)
    if account_alias = AccountAlias.find_by_destroyed_account_id(params[:id])
      redirect_to :id => account_alias.account_id
    else
      respond_to_not_found_without_merged
    end
  end
  #alias_method_chain :respond_to_not_found, :merged

end
