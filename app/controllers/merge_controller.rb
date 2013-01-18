#
# FFCRM Merge plugin
# Copyright (C) 2013 by Crossroads Foundation
#
class MergeController < EntitiesController

  skip_load_and_authorize_resource :only => [:into]

  respond_to :html, :js
  
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
          flash[:error] = I18n.t('assets_merge_error', :assets => klass.to_s.tableize)
        end
      end
    end

    respond_with(@duplicate)
  end

  #~ rescue_from CanCan::AccessDenied do |exception|
    #~ redirect_to root_url, :alert => exception.message
  #~ end

protected

  # Override entity controller
  def klass
    name = params[:klass_name].classify
    klass = (ENTITIES.include?(name) ? name.constantize : nil)
  end

  def do_merge(master, duplicate)
    # Prepare the fields we want to ignore from the duplicate contact.
    ignored = {"_self" => params["ignore"]["_self"].map{|k,v| k if v == "yes" }.compact}
    duplicate.merge_with(master, ignored)
  end

end
