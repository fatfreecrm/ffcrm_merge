require 'spec_helper'

describe AccountsController do

  before(:each) do
    login
    @account = FactoryGirl.create(:account)
    FactoryGirl.create(:account_alias, :account => @account, :destroyed_account_id => 10000)
  end

  describe "GET accounts/10000" do

    it "should find the destroyed account" do
      get :show, :id => 10000
      response.should redirect_to( account_path(:id => @account.id) )
    end

  end

end
