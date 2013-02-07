Rails.application.routes.draw do

  match 'merge/:klass_name/:duplicate_id/into/:master_id', :controller => 'merge', :action => 'into', :as => :into_merge
  match 'merge/:klass_name/aliases', :controller => 'merge', :action => 'aliases', :as => :aliases_merge

end
