require 'spec_helper'

describe ContactsController do
  describe "routing" do
    it "generates merge route for contacts" do
      { :get => "contacts/5/merge/7" }.should route_to(:id => "5",
                                                        :controller => "contacts",
                                                        :action => "merge",
                                                        :master_id => "7")
    end
  end
end
