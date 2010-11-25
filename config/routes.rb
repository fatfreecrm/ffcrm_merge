FatFreeCRM::Application.routes.draw do

  match '/contacts/:id/merge/:master_id',
          :controller => 'contacts',
          :action => 'merge',
          :as => :merge_contact
          
  match '/accounts/:id/merge/:master_id',
          :controller => 'accounts',
          :action => 'merge',
          :as => :merge_account

end
