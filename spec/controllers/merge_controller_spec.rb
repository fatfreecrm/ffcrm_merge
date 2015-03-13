require 'rails_helper'

describe MergeController, type: 'controller' do

  let(:master) { FactoryGirl.create(:contact) }
  let(:duplicate) { FactoryGirl.create(:contact) }

  before(:each) do
    login
  end

  describe "GET merge contact 1 into 2" do

    it do
      get :into, klass_name: 'contact', duplicate_id: duplicate.id, master_id: master.id
      expect(response).to render_template('merge/into')
      expect(assigns(:master)).to eq(master)
      expect(assigns(:duplicate)).to eq(duplicate)
    end

    it "should raise error when master is not authorized" do
      master = FactoryGirl.create(:contact, access: 'Private')
      expect{get :into, klass_name: 'contact', duplicate_id: duplicate.id, master_id: master.id}.to raise_error(CanCan::AccessDenied)
    end

    it "when master does not exist" do
      expect{get :into, klass_name: 'contact', duplicate_id: duplicate.id, master_id: '123123'}.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "should raise error when duplicate is not authorized" do
      duplicate = FactoryGirl.create(:contact, access: 'Private')
      expect{get :into, klass_name: 'contact', duplicate_id: duplicate.id, master_id: master.id}.to raise_error(CanCan::AccessDenied)
    end

    it "when duplicate does not exist" do
      expect{get :into, klass_name: 'contact', duplicate_id: '123321', master_id: master.id}.to raise_error(ActiveRecord::RecordNotFound)
    end

  end

  describe "POST merge contact 1 into 2" do

    it do
      expect(controller).to receive(:do_merge).and_return(true)
      patch :into, klass_name: 'contact', duplicate_id: duplicate.id, master_id: master.id
      expect(response).to render_template('merge/into')
      expect(assigns(:master)).to eq(master)
      expect(assigns(:duplicate)).to eq(duplicate)
    end

    it "should handle failure" do
      expect(controller).to receive(:do_merge).and_return(false)
      patch :into, klass_name: 'contact', duplicate_id: duplicate.id, master_id: master.id
      expect(flash[:error]).to eql("Sorry, an error occurred while trying to merge contacts. The contacts have not been merged.")
      expect(response).to render_template('merge/into')
    end

  end

  describe "aliases" do
    # /merge/contact/aliases?ids=1,2,3,4
    it "should call ids_with_alias and return alias map" do
      FactoryGirl.create(:contact_alias, destroyed_contact_id: 1, contact_id: 5)
      FactoryGirl.create(:contact_alias, destroyed_contact_id: 3, contact_id: 5)
      expect(controller).to receive(:require_application).and_return(true)
      xhr :get, :aliases, klass_name: 'contact', ids: '1,2,3,4'
      expect(response.status).to eql(200)
      expect(response).to render_template('merge/aliases')
      expect(assigns(:aliases)).to eql({'1' => '5', '3' => '5'})
    end

    it "should return 401 unauthorized" do
      xhr :get, :aliases, klass_name: 'contact', ids: '1,2,3,4'
      expect(response.status).to eql(401)
    end
  end

end
