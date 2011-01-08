ActionController::Routing::Routes.draw do |map|
  map.merge_contact "/contacts/:id/merge/:master_id",  :controller => "contacts",    
                    :action => "merge"

  map.merge_account "/accounts/:id/merge/:master_id",  :controller => "accounts",    
                     :action => "merge"
end
