Rails.application.routes.draw do

  match '/contacts/:id/merge/:master_id',
          :controller => 'contacts',
          :action => 'merge',
          :as => :merge_contact
          
  match '/accounts/:id/merge/:master_id',
          :controller => 'accounts',
          :action => 'merge',
          :as => :merge_account
          
  match '/contacts/:id/showmerge/:master_id',
          :controller => 'merge',
          :action => 'showmerge',
          :as => :showmerge_contact

end
