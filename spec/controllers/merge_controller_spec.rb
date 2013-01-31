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
    
    pending "when master is not authorized"    
    pending "when master does not exist"
    
    pending "when duplicate is not authorized"    
    pending "when duplicate does not exist"
    
  end

  describe "POST merge contact 1 into 2" do

    it do
      get :into, :klass_name => 'contact', :duplicate_id => duplicate.id, :master_id => master.id
      response.should render_template('merge/into')
      expect(assigns(:master)).to eq(master)
      expect(assigns(:duplicate)).to eq(duplicate)
    end

    pending "fails"
    
    pending "when master is not authorized"    
    pending "when master does not exist"
    
    pending "when duplicate is not authorized"    
    pending "when duplicate does not exist"

  end

end
