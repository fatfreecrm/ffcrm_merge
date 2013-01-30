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

  it "should include associations" do
    @duplicate.merge_with(@master)
    @master.reload
    
    emails = @duplicate.emails.dup
    comments = @duplicate.comments.dup
    opportunities = @duplicate.opportunities.dup
    tasks = @duplicate.tasks.dup
    addresses = @duplicate.addresses.dup
    tags = @duplicate.tags.dup
    
    expect(@master.user).to eq(@duplicate.user)
    expect(@master.lead).to eq(@duplicate.lead)
    expect(@master.account).to eq(@duplicate.account)

    expect(@master.emails.size).to eq(2)
    expect(@master.emails).to include(*emails)
    expect(@master.comments.size).to eq(2)
    expect(@master.comments).to include(*comments)
    expect(@master.opportunities.size).to eq(2)
    expect(@master.opportunities).to include(*opportunities)
    expect(@master.tasks.size).to eq(2)
    expect(@master.tasks).to include(*tasks)
    expect(@master.addresses.size).to eq(2)
    expect(@master.addresses).to include(*addresses)
    expect(@master.tags.size).to eq(4)
    expect(@master.tags).to include(*tags)
  end
  
  it "should copy all duplicate attributes" do
    @duplicate.merge_with(@master)
    expect(@master.merge_attributes).to eq(@duplicate.merge_attributes)
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
    expect(@master.assigned_to).to eql(duplicate_attributes['assigned_to'])
    expect(@master.department).to eql(duplicate_attributes['department'])
    expect(@master.email).to eql(duplicate_attributes['email'])
    expect(@master.mobile).to eql(duplicate_attributes['mobile'])
    expect(@master.blog).to eql(duplicate_attributes['blog'])
    expect(@master.do_not_call).to eql(duplicate_attributes['do_not_call'])
    expect(@master.born_on).to eql(duplicate_attributes['born_on'])
  end
  
  pending "should merge custom fields"

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

  describe "merge failure" do

    it "validation error should return false" do
      @master.should_receive('save!').and_return(false)
      expect(@duplicate.merge_with(@master)).to be_false
    end

    pending "should rollback the transaction" do
      duplicate_attributes = @duplicate.merge_attributes.dup
      master_attributes = @master.merge_attributes.dup

      #~ @master.should_receive(:tag_list=).and_return(lambda { raise "tag_list error" })
      ContactAlias.should_receive(:create).and_return(lambda { raise "active_record error" })
      expect(@duplicate.merge_with(@master)).to raise_error

      @master.reload
      # check master attributes are rolled back
      expect(@master.first_name).to eql(master_attributes['first_name'])
      expect(@master.email).to eql(master_attributes['email'])
      expect(@master.source).to eql(master_attributes['source'])
      expect(@master.phone).to eql(master_attributes['phone'])

      # check association assigments are rolled back
      expect(@master.user).to eq(master_attributes['user'])
      expect(@master.lead).to eq(master_attributes['lead'])
      expect(@master.account).to eq(master_attributes['account'])

    end
  
  end

end
