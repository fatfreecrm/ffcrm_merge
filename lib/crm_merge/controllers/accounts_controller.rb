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

    @account = Account.my(@current_user).find(params[:id])
    @master_account = Account.my(@current_user).find(params[:master_id])

    # Reverse the master and duplicate if :reverse_merge is true
    @reverse_merge = params[:reverse_merge] == "true" ? true : false
    c = [@account, @master_account]
    duplicate, master = @reverse_merge ? c.reverse : c

    unless duplicate.merge_with(master, ignored_merge_fields)
      @account.errors.add_to_base(t('assets_merge_error', :assets => "accounts"))
    end

    respond_to do |format|
      format.js
    end

    rescue ActiveRecord::RecordNotFound
      respond_to_not_found(:js, :xml)
  end


  # Overwrite auto_complete just for AccountsController,
  # giving the ability to ignore specific account ids.
  #----------------------------------------------------
  def auto_complete
    @query = params[:auto_complete_query]
    @auto_complete = hook(:auto_complete, self, :query => @query, :user => @current_user)
    # Filter out ignored account(s) if param was given.
    if params[:ignored]
      ignored_ids = params[:ignored].split(",").map{|i| i.to_i }
      if @auto_complete[0] # Edge rails 2.3.8 Fat Free CRM
        @auto_complete[0] = @auto_complete[0].select{|a| !ignored_ids.include?(a.id) }
      else                 # Release 0.10.1 (@a897de7)
        @auto_complete = @auto_complete.select{|a| !ignored_ids.include?(a.id) }
      end
    end
    if @auto_complete.empty?
      @auto_complete = controller_name.classify.constantize.my(:user => @current_user, :limit => 10).search(@query)
    else
      @auto_complete = @auto_complete.last
    end
    session[:auto_complete] = controller_name.to_sym
    render :template => "common/auto_complete", :layout => nil
  end


  # GET /accounts/1/edit                                                   AJAX
  #----------------------------------------------------------------------------
  def edit
    @account  = Account.my(@current_user).find(params[:id])

    # 'master_account' lookup for a merge request.
    @master_account = Account.my(@current_user).find(params[:merge_into]) if params[:merge_into]

    @users    = User.except(@current_user).all
    if params[:previous].to_s =~ /(\d+)\z/
      @previous = Account.my(@current_user).find($1)
    end

  rescue ActiveRecord::RecordNotFound
    @previous ||= $1.to_i
    respond_to_not_found(:js) unless @account
  end


  # GET /accounts/1
  # GET /accounts/1.xml                                                    HTML
  #----------------------------------------------------------------------------
  def show_with_alias_fallback
    if account_alias = AccountAlias.find_by_destroyed_account_id(params[:id])
      @account = Account.my(@current_user).find(account_alias.account_id)
      @stage = Setting.unroll(:opportunity_stage)
      @comment = Comment.new

      @timeline = Timeline.find(@account)

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @account }
      end
    else
      # Falls back to original controller method if account is not destroyed
      show_without_alias_fallback
    end
  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:html, :xml)
  end
  alias_method_chain :show, :alias_fallback
  

  # PUT /accounts/1
  # PUT /accounts/1.xml                                                    AJAX
  #----------------------------------------------------------------------------
  def update
    @account = Account.my(@current_user).find(account_alias_or_default(params[:id]))

    respond_to do |format|
      if @account.update_with_permissions(params[:account], params[:users])
        format.js
        format.xml  { head :ok }
      else
        @users = User.except(@current_user).all
        format.js
        format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
      end
    end

  rescue ActiveRecord::RecordNotFound
    respond_to_not_found(:js, :xml)
  end

  private

  # Looks up the AccountAlias table to see if the requested id
  # matches a previously merged account.
  # Returns the new id if it does,
  def account_alias_or_default(account_id)
    if account_alias = AccountAlias.find_by_destroyed_account_id(account_id)
      account_alias.account_id
    else
      account_id
    end
  end

end

