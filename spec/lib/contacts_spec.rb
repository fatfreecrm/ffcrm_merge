require 'spec_helper'

describe "when merging contacts" do
  before :each do
    @master = FactoryGirl.create(:contact, :title => "Master Contact",
      :source => "Master Source", :background_info => "Master Background Info", :tag_list => 'tag1, tag2, tag3')
    @duplicate = FactoryGirl.create(:contact, :title => "Duplicate Contact",
      :source => "Duplicate Source", :background_info => "Duplicate Background Info", :tag_list => 'tag3, tag4')
    FactoryGirl.create(:email, :mediator => @master)
    FactoryGirl.create(:comment, :commentable => @master)
    FactoryGirl.create(:email, :mediator => @duplicate)
    FactoryGirl.create(:comment, :commentable => @duplicate)
    FactoryGirl.create(:address, :addressable => @master)
    FactoryGirl.create(:address, :addressable => @duplicate)
    @master.tasks << FactoryGirl.create(:task)
    @duplicate.tasks << FactoryGirl.create(:task)
    @master.opportunities << FactoryGirl.create(:opportunity)
    @duplicate.opportunities << FactoryGirl.create(:opportunity)
  end
  
  it "should always ignore certain attributes" do
    expect(@master.merge_attributes.keys).to_not include(@master.ignored_merge_attributes)
  end
  
  it "should not merge into itself" do
    expect(@master.merge_with(@master)).to be_false
  end
  
  it "should return true" do
    expect(@duplicate.merge_with(@master)).to be_true
  end
  
  it "should delete the duplicate" do
    expect(Contact.where(:id => @duplicate.id).first).to eql(@duplicate)
    @duplicate.merge_with(@master)
    expect(Contact.where(:id => @duplicate.id).first).to be_nil
  end
  
  it "should call merge hook" do
    @master.should_receive(:merge_hook).with(@duplicate)
    @duplicate.merge_with(@master)
  end

  describe "one to one associations" do
  
    it "should take duplicate item" do
      user_id = @duplicate.user_id
      lead_id = @duplicate.lead_id
      assigned_to = @duplicate.assigned_to
      business_address = @duplicate.business_address
      
      @duplicate.merge_with(@master)
      
      expect(@master.user_id).to eq(user_id)
      expect(@master.lead_id).to eq(lead_id)
      expect(@master.assigned_to).to eq(assigned_to)
      expect(@master.business_address).to eq(business_address)
    end
    
    it "should ignore some duplicate attributes" do
      user_id = @master.user_id
      lead_id = @master.lead_id
      assigned_to = @master.assigned_to
      business_address = @master.business_address
      
      @duplicate.merge_with(@master, %w(user_id lead_id assigned_to business_address))
      @master.reload
      
      expect(@master.user_id).to eq(user_id)
      expect(@master.lead_id).to eq(lead_id)
      expect(@master.assigned_to).to eq(assigned_to)
      expect(@master.business_address).to eq(business_address)
    end

  end
  
  describe "many to many associations" do

    it "should be combined" do
      emails = @duplicate.emails.dup
      comments = @duplicate.comments.dup
      opportunities = @duplicate.opportunities.dup
      tasks = @duplicate.tasks.dup
      tags = @duplicate.tags.dup
      account_contact_ids = @duplicate.account_contact.id
      
      @duplicate.merge_with(@master)
      @master.reload
      
      expect(@master.emails.size).to eq(2)
      expect(@master.emails).to include(*emails)
      expect(@master.comments.size).to eq(2)
      expect(@master.comments).to include(*comments)
      expect(@master.opportunities.size).to eq(2)
      expect(@master.opportunities).to include(*opportunities)
      expect(@master.tasks.size).to eq(2)
      expect(@master.tasks).to include(*tasks)
      expect(@master.tags.size).to eq(4)
      expect(@master.tags).to include(*tags)
      expect(AccountContact.where(:contact_id => @master).size).to eq(2)
      expect(AccountContact.where(:contact_id => @master).map(&:id)).to include(*account_contact_ids)
    end
  
  end
  
  it "should copy all duplicate attributes but exclude addresses" do
    duplicate_merge_attributes = @duplicate.merge_attributes
    @duplicate.merge_with(@master)
    expect(@master.merge_attributes).to eq(duplicate_merge_attributes)
  end
  
  it "should be able to ignore some of the duplicate attributes when merging" do
    ignored_attributes = %w(title source background_info phone fax linkedin first_name alt_email)
    duplicate_attributes = @duplicate.merge_attributes.dup
    master_attributes = @master.merge_attributes.dup

    @duplicate.merge_with(@master, ignored_attributes)

    # Check that the merge has ignored some duplicate attributes
    expect(@master.title).to eql(master_attributes['title'])
    expect(@master.source).to eql(master_attributes['source'])
    expect(@master.background_info).to eql(master_attributes['background_info'])
    expect(@master.phone).to eql(master_attributes['phone'])
    expect(@master.fax).to eql(master_attributes['fax'])
    expect(@master.linkedin).to eql(master_attributes['linkedin'])
    expect(@master.first_name).to eql(master_attributes['first_name'])
    expect(@master.alt_email).to eql(master_attributes['alt_email'])

    # Check that the merge has included some duplicate attributes
    expect(@master.last_name).to eql(duplicate_attributes['last_name'])
    expect(@master.access).to eql(duplicate_attributes['access'])
    expect(@master.facebook).to eql(duplicate_attributes['facebook'])
    expect(@master.twitter).to eql(duplicate_attributes['twitter'])
    expect(@master.department).to eql(duplicate_attributes['department'])
    expect(@master.assigned_to).to eql(duplicate_attributes['assigned_to'])
    expect(@master.email).to eql(duplicate_attributes['email'])
    expect(@master.mobile).to eql(duplicate_attributes['mobile'])
    expect(@master.blog).to eql(duplicate_attributes['blog'])
    expect(@master.do_not_call).to eql(duplicate_attributes['do_not_call'])
    expect(@master.born_on).to eql(duplicate_attributes['born_on'])
  end
  
  # this is the exact opposite of the test above... that way we cover all cases
  it "should be able to ignore some of the duplicate attributes when merging 2" do
    ignored_attributes = %w(last_name access facebook twitter assigned_to department email mobile blog do_not_call born_on)
    duplicate_attributes = @duplicate.merge_attributes.dup
    master_attributes = @master.merge_attributes.dup
    @duplicate.merge_with(@master, ignored_attributes)

    # Check that the merge has ignored some duplicate attributes
    expect(@master.last_name).to eql(master_attributes['last_name'])
    expect(@master.access).to eql(master_attributes['access'])
    expect(@master.facebook).to eql(master_attributes['facebook'])
    expect(@master.twitter).to eql(master_attributes['twitter'])
    expect(@master.assigned_to).to eql(master_attributes['assigned_to'])
    expect(@master.department).to eql(master_attributes['department'])
    expect(@master.email).to eql(master_attributes['email'])
    expect(@master.mobile).to eql(master_attributes['mobile'])
    expect(@master.blog).to eql(master_attributes['blog'])
    expect(@master.do_not_call).to eql(master_attributes['do_not_call'])
    expect(@master.born_on).to eql(master_attributes['born_on'])

    # Check that the merge has included some duplicate attributes
    expect(@master.title).to eql(duplicate_attributes['title'])
    expect(@master.source).to eql(duplicate_attributes['source'])
    expect(@master.background_info).to eql(duplicate_attributes['background_info'])
    expect(@master.phone).to eql(duplicate_attributes['phone'])
    expect(@master.fax).to eql(duplicate_attributes['fax'])
    expect(@master.linkedin).to eql(duplicate_attributes['linkedin'])
    expect(@master.first_name).to eql(duplicate_attributes['first_name'])
    expect(@master.alt_email).to eql(duplicate_attributes['alt_email'])
  end
  
  describe "contact alias" do
  
    it "should be created" do
      @duplicate.merge_with(@master)
      ca = ContactAlias.where(:destroyed_contact_id => @duplicate.id).first
      expect(ca.contact).to eq(@master)
    end

    it "should update existing aliases pointing to the duplicate record" do
      @ca1 = ContactAlias.create(:contact => @duplicate, :destroyed_contact_id => 12345)
      @ca2 = ContactAlias.create(:contact => @duplicate, :destroyed_contact_id => 23456)
      @duplicate.merge_with(@master)
      expect(ContactAlias.where(:destroyed_contact_id => 12345).first.contact_id).to eql(@master.id)
      expect(ContactAlias.where(:destroyed_contact_id => 23456).first.contact_id).to eql(@master.id)
    end
    
  end

  describe "a merge failure" do

    it "validation error should return false" do
      @master.should_receive('save!').and_return(false)
      expect(@duplicate.merge_with(@master)).to be_false
    end

    it "should rollback the transaction", :testing_transactions => true do
    
      pending "Rspec wraps each test in a transaction and that interferes with testing transaction rollback"
    
      duplicate_attributes = @duplicate.merge_attributes.dup
      master_attributes = @master.merge_attributes.dup

      @duplicate.should_receive(:destroy).and_raise(StandardError, "merge error")
      expect(lambda { @duplicate.merge_with(@master) }).to raise_error(StandardError, "merge error")

      #
      # From the docs: Exceptions will force a ROLLBACK that returns the database to the state before the transaction began.
      # Be aware, though, that the objects will not have their instance data returned to their pre-transactional state.
      # This is why we have to reload the instance here.
      #
      @master.reload
      @duplicate.reload

      # check master attributes are rolled back
      expect(@master.first_name).to eql(master_attributes['first_name'])
      expect(@master.email).to eql(master_attributes['email'])
      expect(@master.source).to eql(master_attributes['source'])
      expect(@master.phone).to eql(master_attributes['phone'])

      # check association assigments are rolled back
      expect(@master.user_id).to eq(master_attributes['user_id'])
      expect(@master.lead_id).to eq(master_attributes['lead_id'])
      expect(@master.account_id).to eq(master_attributes['account_id'])

    end
  
  end

end
