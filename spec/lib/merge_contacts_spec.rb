require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Contact do
  before :each do
    @contact = Factory(:contact)
    @dup_contact = Factory(:contact)
    4.times do
      Factory(:email, :mediator => @contact)
      Factory(:email, :mediator => @dup_contact)
    end
  end

  it "should be able to merge itself into another contact" do
    # Save the attributes we want to match
    dup_contact_attr = @dup_contact.merge_attributes
    dup_contact_emails = @dup_contact.emails

    @dup_contact.merge_with(@contact)

    # Check that the duplicate contact has been merged
    @contact.merge_attributes.should == dup_contact_attr
    @contact.user.should == @dup_contact.user
    @contact.lead.should == @dup_contact.lead
    @contact.account.should == @dup_contact.account

    dup_contact_emails.each do |email|
      @contact.emails.include?(email).should == true
    end
  end

  it "should be able to ignore some attributes when merging" do
    ignored_attributes = %w(title source background_info)

    # Save the attributes we want to match
    dup_contact_attr = @dup_contact.merge_attributes

    @dup_contact.merge_with(@contact, %w(title source background_info))

    # Check that the duplicate contact has ignored some attributes
    ignored_attributes.each do |attr|
      @contact.send(attr.to_sym).should_not == dup_contact_attr[attr]
    end
    # Check that other fields have been merged
    %w(first_name last_name access facebook twitter).each do |attr|
      @contact.send(attr.to_sym).should == dup_contact_attr[attr]
    end
  end
end

