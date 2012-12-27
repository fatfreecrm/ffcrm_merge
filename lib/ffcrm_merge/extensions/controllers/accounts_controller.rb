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

  # PUT /accounts/1/merge/2                                                AJAX
  #----------------------------------------------------------------------------
  def merge
    # Find which fields we want to ignore from the duplicate account.
    ignored_merge_fields = params[:ignore].select{|k,v| v == "yes" }.map{|a| a[0] }

    @master_account = Account.my.find(params[:master_id])

    # Reverse the master and duplicate if :reverse_merge is true
    @reverse_merge = params[:reverse_merge] == "true" ? true : false
    c = [@account, @master_account]
    duplicate, master = @reverse_merge ? c.reverse : c

    unless duplicate.merge_with(master, ignored_merge_fields)
      @account.errors.add_to_base(t('assets_merge_error', :assets => "accounts"))
    end

    get_data_for_sidebar
    respond_with(@account)
  end


  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    # 'master_account' lookup for a merge request.
    @master_account = Account.my.find(params[:merge_into]) if params[:merge_into]

    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Account.my.find_by_id($1) || $1.to_i
    end

    respond_with(@account)
  end

  private

  #----------------------------------------------------------------------------
  def respond_to_not_found_with_merged(*types)
    if account_alias = AccountAlias.find_by_destroyed_account_id(params[:id])
      redirect_to :id => account_alias.account_id
    else
      respond_to_not_found_without_merged
    end
  end
  alias_method_chain :respond_to_not_found, :merged
end
