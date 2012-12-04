#
# FFCRM Merge plugin
# Copyright (C) 2012 by Crossroads Foundation
#

class MergeController < EntitiesController
    
  before_filter :require_user
  skip_load_and_authorize_resource

  # GET /contacts/1/showmerge/2                                            HTML
  #----------------------------------------------------------------------------
  def showmerge
    @master_contact = Contact.my.find(params[:master_id])
    @contact = Contact.my.find(params[:id])
  end

end
