require "rails_helper"

RSpec.describe "Redirect merged", type: :request do

  let(:deleted_id) { 10000 }

  before(:each) do
    login
    allow_any_instance_of(AccountsController).to receive("set_current_tab")
    allow_any_instance_of(ContactsController).to receive("set_current_tab")
  end

  describe "accounts" do
    let(:subject) { FactoryBot.create(:account) }
    it do
      FactoryBot.create(:account_alias, account: subject, destroyed_account_id: deleted_id)
      get "/accounts/#{deleted_id}"
      expect(response).to redirect_to(subject)
    end
    it "normal behaviour" do
      expect{get "/accounts/12345"}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "contacts" do
    let(:subject) { FactoryBot.create(:contact) }
    it do
      FactoryBot.create(:contact_alias, contact: subject, destroyed_contact_id: deleted_id)
      get "/contacts/#{deleted_id}"
      expect(response).to redirect_to(subject)
    end
    it "normal behaviour" do
      expect{get "/contacts/12345"}.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
