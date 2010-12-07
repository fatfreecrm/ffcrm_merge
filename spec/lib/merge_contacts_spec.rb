require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Contact do
  before :each do
    @contact     = Factory(:contact,
                           :title           => "Master Contact",
                           :source          => "Master Source",
                           :background_info => "Master Background Info")
    @dup_contact = Factory(:contact,
                           :title           => "Duplicate Contact",
                           :source          => "Duplicate Source",
                           :background_info => "Duplicate Background Info")
    4.times do
      Factory(:email, :mediator => @contact)
      Factory(:email, :mediator => @dup_contact)
      Factory(:comment, :commentable => @contact)
      Factory(:comment, :commentable => @dup_contact)      
    end
  end

  it "should be able to merge itself into another contact" do
    # Store the attributes we want to match
    dup_contact_attr  = @dup_contact.merge_attributes
    dup_has_many_hash = {:emails        => @dup_contact.emails.dup,
                         :comments      => @dup_contact.comments.dup,
                         :opportunities => @dup_contact.opportunities.dup,
                         :tasks         => @dup_contact.tasks.dup}

    @dup_contact.merge_with(@contact)

    # Check that the duplicate contact has been merged
    @contact.merge_attributes.should == dup_contact_attr
    @contact.user.should             == @dup_contact.user
    @contact.lead.should             == @dup_contact.lead
    @contact.account.should          == @dup_contact.account

    # Check that all 'has_many' associations have been transferred
    # from the duplicate to the master.
    dup_has_many_hash.each do |method, collection|
      collection.each do |asset|
        @contact.send(method).include?(asset).should == true
      end
    end

    # Duplicate contacts activities should have been destroyed.
    @dup_contact.activities.should be_empty

    # Check that the contact alias has been created correctly.
    ContactAlias.find_by_destroyed_contact_id(@dup_contact.id).contact.should == @contact
  end

  it "should be able to ignore some attributes when merging" do
    ignored_attributes = %w(title source background_info)

    # Save the attributes we want to match
    dup_contact_attr = @dup_contact.merge_attributes

    @dup_contact.merge_with(@contact, ignored_attributes)

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

