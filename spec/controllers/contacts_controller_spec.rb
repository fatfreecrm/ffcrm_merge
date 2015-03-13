require 'rails_helper'

describe ContactsController, type: 'controller' do

  let(:contact) { FactoryGirl.create(:contact) }

  before(:each) do
    FactoryGirl.create(:contact_alias, contact: contact, destroyed_contact_id: 10000)
  end

  describe "GET contacts/10000" do
    it "should find the destroyed contact" do
      get :show, id: 10000
      expect(response).to redirect_to(contact_path(id: contact.id))
    end
  end

  describe "GET contacts/10001" do
    it "should redirect to /contacts" do
      get :show, id: 10001
      expect(response).to redirect_to(contacts_path)
    end
  end

end
