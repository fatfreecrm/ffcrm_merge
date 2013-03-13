#
# FFCRM Merge plugin
# Copyright (C) 2013 by Crossroads Foundation
#
class MergeController < EntitiesController

  skip_load_and_authorize_resource :only => [:into, :aliases]
  skip_before_filter :require_user, :only => :aliases
  before_filter :require_application, :only => :aliases

  respond_to :html, :js

  helper_method :klass

  # GET  /merge/contact/1/into/2                                           HTML
  # GET  /merge/contact/1/into/2                                             JS
  # PUT  /merge/account/1/into/2                                           HTML
  # PUT  /merge/account/1/into/2                                             JS
  def into
    @previous = params[:previous]
    @master = klass.find(params[:master_id])
    authorize! :manage, @master
    @duplicate = klass.find(params[:duplicate_id])
    authorize! :manage, @duplicate

    # don't merge if either is invalid to start with
    if !valid_object?(@master)
      flash[:error] = I18n.t('assets_merge_invalid', :name => @master.name)
    elsif !valid_object?(@duplicate)
      flash[:error] = I18n.t('assets_merge_invalid', :name => @duplicate.name)
    elsif request.put?
      do_merge(@master, @duplicate)
      @success = true # do_merge will throw error if problem
      flash[:error] = I18n.t('assets_merge_error', :assets => klass.to_s.humanize) unless @success
    end

    respond_with(@duplicate)
  end

  #
  # List out the aliases for a given set of contact ids
  #
  # GET   /merge/contact/aliases?ids=1,2,3,4&format=js                          JS
  # POST  /merge/contact/aliases?ids=1,2,3,4&format=js                          JS
  def aliases
    model_name = "#{klass}Alias".constantize        # klass is carefully sanitized
    @aliases = model_name.ids_with_alias( santize_ids )
    respond_to do |format|
      format.js # aliases.js.erb
    end
  end

protected

  def respond_to_access_denied
    flash[:warning] = t(:msg_asset_not_authorized, klass.to_s.humanize.downcase)
    redirect_to :controller => klass.to_s.underscore.pluralize, :action => :index
  end

  def respond_to_not_found
    flash[:warning] = t(:msg_asset_not_available, klass.to_s.humanize.downcase)
    redirect_to :controller => klass.to_s.underscore.pluralize, :action => :index
  end

  # Override entity controller, this must be carefully sanitized so arbitary klasses aren't allowed
  def klass
    name = params[:klass_name].classify
    klass = (ENTITIES.include?(name) ? name.constantize : nil)
  end

  # Carefully sanitize params[:ids] by converting to integers and remove 0's since 'test'.to_i == 0
  def santize_ids
    (params[:ids] || []).split(',').flatten.map(&:to_i).reject{|x| x == 0}.compact
  end

  def do_merge(master, duplicate)
    # Prepare the fields we want to ignore from the duplicate contact.
    ignored = params["ignore"]["_self"].map{|k,v| k if v == "yes" }.compact
    duplicate.merge_with(master, ignored)
  end

  # rudimentary API KEY authentication for the aliases action
  def require_application
    error = ""
    if !Setting.ffcrm_merge.present?
      error = 'No api key defined in Setting.ffcrm_merge. Rejecting all requests.'
    elsif params[:api_key] == Setting.ffcrm_merge[:api_key]
      return true # skip the error rendering
    else
      error = 'Please specify a valid api_key in the url.'
    end

    render :js => {:errors => error}.to_json
    false
  end

  # Return true if object is valid, except in case where object is account
  # AND just account name is duplicate. That case is dealt with during the merge
  def valid_object?(obj)

    if obj.class.to_s == 'Account'
      v = obj.valid?
      obj.errors.keys.compact == [:name] || v
    else
      obj.valid?
    end

  end

end
