require 'spec_helper'

describe MergeController do

  let(:master) { FactoryGirl.create(:contact) }
  let(:duplicate) { FactoryGirl.create(:contact) }
  
  before(:each) do
    login
  end
  
  describe "GET merge contact 1 into 2" do
  
    it do
      get :into, :klass_name => 'contact', :duplicate_id => duplicate.id, :master_id => master.id
      response.should render_template('merge/into')
      expect(assigns(:master)).to eq(master)
      expect(assigns(:duplicate)).to eq(duplicate)
    end
    
    it "should raise error when master is not authorized" do
      master = FactoryGirl.create(:contact, :access => 'Private')
      get :into, :klass_name => 'contact', :duplicate_id => duplicate.id, :master_id => master.id
      expect(flash[:warning]).to eql("You are not authorized to view this contact.")
    end

    it "when master does not exist" do
      get :into, :klass_name => 'contact', :duplicate_id => duplicate.id, :master_id => '123123'
      expect(flash[:warning]).to eql("This contact is no longer available.")
    end
    
    it "should raise error when duplicate is not authorized" do
      duplicate = FactoryGirl.create(:contact, :access => 'Private')
      get :into, :klass_name => 'contact', :duplicate_id => duplicate.id, :master_id => master.id
      expect(flash[:warning]).to eql("You are not authorized to view this contact.")
    end
    
    it "when duplicate does not exist" do
      get :into, :klass_name => 'contact', :duplicate_id => '123321', :master_id => master.id
      expect(flash[:warning]).to eql("This contact is no longer available.")
    end
    
  end

  describe "POST merge contact 1 into 2" do

    it do
      get :into, :klass_name => 'contact', :duplicate_id => duplicate.id, :master_id => master.id
      response.should render_template('merge/into')
      expect(assigns(:master)).to eq(master)
      expect(assigns(:duplicate)).to eq(duplicate)
    end

    it "should handle failure" do
      pending "Need to fix this."
      controller.should_receive(:do_merge).and_return(false)
      get :into, :klass_name => 'contact', :duplicate_id => duplicate.id, :master_id => master.id
      expect(flash[:error]).to eql("Sorry, an error occurred while trying to merge contacts. The contacts have not been merged.")
      response.should render_template('merge/into')
    end

  end

  describe "aliases" do

    # /merge/contact/aliases?ids=1,2,3,4
    it "should call ids_with_alias and return alias map" do
      FactoryGirl.create(:contact_alias, :destroyed_contact_id => 1, :contact_id => 5)
      FactoryGirl.create(:contact_alias, :destroyed_contact_id => 3, :contact_id => 5)

      get :aliases, :klass_name => 'contact', :ids => '1,2,3,4', :format => :js
      expect(assigns(:aliases)).to eql({'1' => '5', '2' => '2', '3' => '5', '4' => '4'})
    end
    
  end

end
