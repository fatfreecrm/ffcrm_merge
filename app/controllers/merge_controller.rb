#
# FFCRM Merge plugin
# Copyright (C) 2013 by Crossroads Foundation
#
class MergeController < EntitiesController

  skip_load_and_authorize_resource :only => [:into, :aliases]

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
    if !@master.valid?
      flash[:error] = I18n.t('assets_merge_invalid', :name => @master.name)
    elsif !@duplicate.valid?
      flash[:error] = I18n.t('assets_merge_invalid', :name => @duplicate.name)
    else
      if request.put?
        if do_merge(@master, @duplicate)
          redirect_to(@master) and return
        else
          flash[:error] = I18n.t('assets_merge_error', :assets => klass.to_s.humanize)
        end
      end
    end

    respond_with(@duplicate)
  end
  
  #
  # List out the aliases for a given set of contact ids
  #
  # GET  /merge/contact/aliases?ids=1,2,3,4                                   JS
  def aliases
    ids = params.has_key?('ids') ? params[:ids].split(',') : []
    model_name = "#{klass}Alias".constantize    # klass is carefully sanitized
    @aliases = model_name.ids_with_alias(ids)
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

  def do_merge(master, duplicate)
    # Prepare the fields we want to ignore from the duplicate contact.
    ignored = params["ignore"]["_self"].map{|k,v| k if v == "yes" }.compact
    duplicate.merge_with(master, ignored)
  end

end
