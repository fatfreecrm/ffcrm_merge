require 'rails_helper'

describe 'when merging accounts' do
  before :each do
    @master = FactoryBot.create(:account, name: "Master account",
      email: "master@example.com", background_info: "Master Background Info", tag_list: 'tag1, tag2, tag3')
    @duplicate = FactoryBot.create(:account, name: "Duplicate account",
      email: "duplicate@example.com", background_info: "Duplicate Background Info", tag_list: 'tag3, tag4')
    FactoryBot.create(:email, mediator: @master)
    FactoryBot.create(:comment, commentable: @master)
    FactoryBot.create(:email, mediator: @duplicate)
    FactoryBot.create(:comment, commentable: @duplicate)
    FactoryBot.create(:address, addressable: @master, address_type: 'Billing')
    FactoryBot.create(:address, addressable: @duplicate, address_type: 'Billing')
    FactoryBot.create(:address, addressable: @master, address_type: 'Shipping')
    FactoryBot.create(:address, addressable: @duplicate, address_type: 'Shipping')
    @master.tasks << FactoryBot.create(:task)
    @duplicate.tasks << FactoryBot.create(:task)
    @master.opportunities << FactoryBot.create(:opportunity)
    @duplicate.opportunities << FactoryBot.create(:opportunity)
    @master.contacts << FactoryBot.create(:contact)
    @duplicate.contacts << FactoryBot.create(:contact)
  end
    
  it "should always ignore certain attributes" do
    expect(@master.merge_attributes.keys).to_not include(@master.ignored_merge_attributes)
  end
  
  it "should not merge into itself" do
    expect(@master.merge_with(@master)).to eql(false)
  end
  
  it "should return true" do
    expect(@duplicate.merge_with(@master)).to eql(true)
  end
  
  it "should delete the duplicate" do
    expect(Account.where(:id => @duplicate.id).first).to eql(@duplicate)
    @duplicate.merge_with(@master)
    expect(Account.where(:id => @duplicate.id).first).to be_nil
  end
  
  it "should call merge hook" do
    expect(@master).to receive(:merge_hook).with(@duplicate)
    @duplicate.merge_with(@master)
  end

  describe "one to one associations" do
  
    it "should take duplicate item" do
      user_id = @duplicate.user_id
      assigned_to = @duplicate.assigned_to
      billing_address = @duplicate.billing_address
      shipping_address = @duplicate.shipping_address
      
      @duplicate.merge_with(@master)
      
      expect(@master.user_id).to eq(user_id)
      expect(@master.assigned_to).to eq(assigned_to)
      expect(@master.billing_address).to eq(billing_address)
      expect(@master.shipping_address).to eq(shipping_address)
    end
    
    it "should ignore some duplicate attributes" do
      user_id = @master.user_id
      assigned_to = @master.assigned_to
      billing_address = @master.billing_address
      shipping_address = @master.shipping_address

      @duplicate.merge_with(@master, %w(user_id assigned_to billing_address shipping_address))
      @master.reload

      expect(@master.user_id).to eq(user_id)
      expect(@master.assigned_to).to eq(assigned_to)
      expect(@master.billing_address).to eq(billing_address)
      expect(@master.shipping_address).to eq(shipping_address)
    end

  end
  
  describe "many to many associations" do

    it "should be combined" do
      emails = @duplicate.emails.dup
      comments = @duplicate.comments.dup
      opportunities = @duplicate.opportunities.dup
      contacts = @duplicate.contacts.dup
      tasks = @duplicate.tasks.dup
      tags = @duplicate.tags.dup
      
      @duplicate.merge_with(@master)
      @master.reload
      
      expect(@master.emails.size).to eq(2)
      expect(@master.emails).to include(*emails)
      expect(@master.comments.size).to eq(2)
      expect(@master.comments).to include(*comments)
      expect(@master.opportunities.size).to eq(2)
      expect(@master.opportunities).to include(*opportunities)
      expect(@master.contacts.size).to eq(2) # master + duplicate
      expect(@master.contacts).to include(*contacts)
      expect(@master.tasks.size).to eq(2)
      expect(@master.tasks).to include(*tasks)
      expect(@master.tags.size).to eq(4)
      expect(@master.tags).to include(*tags)
    end
  
  end

  it "should copy all duplicate attributes" do
    duplicate_merge_attributes = @duplicate.merge_attributes
    @duplicate.merge_with(@master)
    expect(@master.merge_attributes).to eq(duplicate_merge_attributes)
  end
  
  it "should be able to ignore some of the duplicate attributes when merging" do
    ignored_attributes = %w(name background_info phone fax assigned_to)
    duplicate_attributes = @duplicate.merge_attributes.dup
    master_attributes = @master.merge_attributes.dup
    @duplicate.merge_with(@master, ignored_attributes)

    # Check that the merge has ignored some duplicate attributes
    expect(@master.name).to eql(master_attributes['name'])
    expect(@master.background_info).to eql(master_attributes['background_info'])
    expect(@master.phone).to eql(master_attributes['phone'])
    expect(@master.fax).to eql(master_attributes['fax'])
    expect(@master.assigned_to).to eql(master_attributes['assigned_to'])
    
    # Check that the merge has included some duplicate attributes
    expect(@master.category).to eql(duplicate_attributes['category'])
    expect(@master.toll_free_phone).to eql(duplicate_attributes['toll_free_phone'])
    expect(@master.access).to eql(duplicate_attributes['access'])
    expect(@master.rating).to eql(duplicate_attributes['rating'])

  end
  
  # this is the exact opposite of the previous test 
  it "should be able to ignore some of the duplicate attributes when merging 2" do
    ignored_attributes = %w(category toll_free_phone access rating)
    duplicate_attributes = @duplicate.merge_attributes.dup
    master_attributes = @master.merge_attributes.dup
    @duplicate.merge_with(@master, ignored_attributes)

    # Check that the merge has ignored some duplicate attributes
    expect(@master.category).to eql(master_attributes['category'])
    expect(@master.toll_free_phone).to eql(master_attributes['toll_free_phone'])
    expect(@master.access).to eql(master_attributes['access'])
    expect(@master.rating).to eql(master_attributes['rating'])

    # Check that the merge has included some duplicate attributes
    expect(@master.name).to eql(duplicate_attributes['name'])
    expect(@master.background_info).to eql(duplicate_attributes['background_info'])
    expect(@master.phone).to eql(duplicate_attributes['phone'])
    expect(@master.fax).to eql(duplicate_attributes['fax'])
    expect(@master.assigned_to).to eql(duplicate_attributes['assigned_to'])

  end
  
  it "should successful merge a contact that belong to both accounts without failing" do
    original_master_contacts = @master.contacts.map(&:id)
    original_duplicate_contacts = @duplicate.contacts.map(&:id)
    expected_contacts = Set.new(original_master_contacts) + Set.new(original_duplicate_contacts)
    @master.contacts << @duplicate.contacts
    @duplicate.merge_with(@master)
    expect(@master.contacts.map(&:id)).to eql(expected_contacts.to_a)
  end

  describe "account alias" do
  
    it "should be created" do
      @duplicate.merge_with(@master)
      ca = AccountAlias.where(:destroyed_account_id => @duplicate.id).first
      expect(ca.account).to eq(@master)
    end

    it "should update existing aliases pointing to the duplicate record" do
      @ca1 = AccountAlias.create(:account => @duplicate, :destroyed_account_id => 12345)
      @ca2 = AccountAlias.create(:account => @duplicate, :destroyed_account_id => 23456)
      @duplicate.merge_with(@master)
      expect(AccountAlias.where(:destroyed_account_id => 12345).first.account_id).to eql(@master.id)
      expect(AccountAlias.where(:destroyed_account_id => 23456).first.account_id).to eql(@master.id)
    end
    
  end
  
  describe "a merge failure" do
  
    it "validation error should return false" do
      expect(@master).to receive('save!').and_return(false)
      expect(@duplicate.merge_with(@master)).to eql(false)
    end

  end

end
