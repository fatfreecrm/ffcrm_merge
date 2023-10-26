require 'rails_helper'

describe "merge", type: :request do

  let(:master) { FactoryBot.create(:contact) }
  let(:duplicate) { FactoryBot.create(:contact) }
  
  before(:each) do
    login
  end
  
  describe "GET merge into" do
  
    it do
      get "/merge/contact/#{duplicate.id}/into/#{master.id}"
      expect(response.body).to include("Merge \"#{duplicate.name}\" into \"#{master.name}\"")
    end
    
    it "should raise error when master is not authorized" do
      master.update(access: 'Private')
      get "/merge/contact/#{duplicate.id}/into/#{master.id}"
      expect(flash[:warning]).to eql("You are not authorized to view this contact.")
    end

    it "when master does not exist" do
      get "/merge/contact/#{duplicate.id}/into/123123"
      expect(flash[:warning]).to eql("This contact is no longer available.")
    end
    
    it "should raise error when duplicate is not authorized" do
      duplicate = FactoryBot.create(:contact, access: 'Private')
      get "/merge/contact/#{duplicate.id}/into/#{master.id}"
      expect(flash[:warning]).to eql("You are not authorized to view this contact.")
    end
    
    it "when duplicate does not exist" do
      get "/merge/contact/123321/into/#{master.id}"
      expect(flash[:warning]).to eql("This contact is no longer available.")
    end
    
  end

  describe "POST merge contact 1 into 2" do

    it do
      post "/merge/contact/#{duplicate.id}/into/#{master.id}"
      expect(response.body).to include("Merge \"#{duplicate.name}\" into \"#{master.name}\"")
    end

  end

  describe "aliases" do

    let(:api_key) { 'ajk340fj30-df0-0dfg=23' }
    let(:contact1) { FactoryBot.create(:contact) }
    let(:contact2) { FactoryBot.create(:contact) }
    let(:contact3) { FactoryBot.create(:contact) }

    before(:each) do
      Setting.ffcrm_merge = { 'api_key' => api_key }
    end

    # /merge/contact/aliases?ids=1,2,3
    it "should call ids_with_alias and return alias map" do
      contact1.merge_with(contact2)
      get '/merge/contact/aliases', params: { api_key: api_key, klass_name: 'contact', ids: "#{contact1.id},#{contact2.id},#{contact3.id}", format: :js }, xhr: true
      expect( response.body ).to include( { contact1.id.to_s => contact2.id.to_s }.to_json )
    end
    
  end

end
