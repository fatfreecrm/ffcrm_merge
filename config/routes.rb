FatFreeCrm::Application.routes.draw do

  match '/contacts/:id/merge/:master_id',
          :controller => 'contacts',
          :action => 'merge',
          :as => :merge_contact

end
