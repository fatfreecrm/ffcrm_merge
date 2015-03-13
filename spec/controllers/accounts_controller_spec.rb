require 'rails_helper'

describe AccountsController, type: 'controller' do

  let(:account) { FactoryGirl.create(:account) }

  before(:each) do
    FactoryGirl.create(:account_alias, account: account, destroyed_account_id: 10000)
  end

  describe "GET accounts/10000" do
    it "should find the destroyed account" do
      get :show, id: 10000
      expect(response).to redirect_to(account_path(id: account.id))
    end
  end

  describe "GET accounts/10001" do
    it "should redirect to accounts" do
      get :show, id: 10001
      expect(response).to redirect_to(accounts_path)
    end
  end

end
