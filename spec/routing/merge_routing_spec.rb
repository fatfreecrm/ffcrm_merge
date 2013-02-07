require 'spec_helper'

describe MergeController do
  describe "routing" do
  
    it "generates merge route for contact" do
      expect(:get => "merge/contact/1/into/2").to route_to(:controller => "merge", :klass_name => 'contact', :duplicate_id => "1", :action => "into", :master_id => "2")
    end
    
    it "generates merge route for account" do
      expect(:get => "merge/account/1/into/2").to route_to(:controller => "merge", :klass_name => 'account', :duplicate_id => "1", :action => "into", :master_id => "2")
    end
    
    it "generates alias route for contact" do
      expect(:get => "merge/contact/aliases").to route_to(:controller => "merge", :klass_name => 'contact', :action => "aliases")
    end
    
    it "generates alias route for account" do
      expect(:get => "merge/account/aliases").to route_to(:controller => "merge", :klass_name => 'account', :action => "aliases")
    end
    
  end
end
