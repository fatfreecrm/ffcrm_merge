require 'spec_helper'

describe ContactsController do

  before(:each) do
    login
    @contact = FactoryGirl.create(:contact)
    FactoryGirl.create(:contact_alias, :contact => @contact, :destroyed_contact_id => 10000)
  end

  describe "GET contacts/10000" do

    it "should find the destroyed contact" do
      get :show, :id => 10000
      response.should redirect_to( contact_path(:id => @contact.id) )
    end

  end

end
