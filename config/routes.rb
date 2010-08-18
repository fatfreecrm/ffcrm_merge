ActionController::Routing::Routes.draw do |map|

  map.merge_contact 'contacts/:id/merge/:master_id',
                    :controller => 'contacts',
                    :action => 'merge'

end

