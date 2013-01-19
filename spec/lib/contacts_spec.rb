require 'spec_helper'

describe Contact do
  before :each do
    @master = FactoryGirl.create(:contact, :title => "Master Contact",
      :source => "Master Source", :background_info => "Master Background Info")
    @duplicate = FactoryGirl.create(:contact, :title => "Duplicate Contact",
      :source => "Duplicate Source", :background_info => "Duplicate Background Info")
    2.times do
      FactoryGirl.create(:email, :mediator => @master)
      FactoryGirl.create(:email, :mediator => @duplicate)
      FactoryGirl.create(:comment, :commentable => @master)
      FactoryGirl.create(:comment, :commentable => @duplicate)
    end
  end

  it "should be able to merge itself into another contact" do
    # Store the attributes we want to match
    dup_contact_attr  = @duplicate.merge_attributes
    dup_has_many_hash = {:emails        => @duplicate.emails.dup,
                         :comments      => @duplicate.comments.dup,
                         :opportunities => @duplicate.opportunities.dup,
                         :tasks         => @duplicate.tasks.dup}

    @duplicate.merge_with(@master)

    # Check that the duplicate contact has been merged
    @master.merge_attributes.should == dup_contact_attr
    @master.user.should             == @duplicate.user
    @master.lead.should             == @duplicate.lead
    @master.account.should          == @duplicate.account

    # Check that all 'has_many' associations have been transferred
    # from the duplicate to the master.
    dup_has_many_hash.each do |method, collection|
      collection.each do |asset|
        @master.send(method).include?(asset).should == true
      end
    end

    # Check that the contact alias has been created correctly.
    ContactAlias.find_by_destroyed_contact_id(@duplicate.id).contact.should == @master
  end

  it "should be able to ignore some attributes when merging" do
    ignored_attributes = {"_self" => %w(title source background_info)}

    # Save the attributes we want to match
    dup_contact_attr = @duplicate.merge_attributes

    @duplicate.merge_with(@master, ignored_attributes)

    # Check that the duplicate contact has ignored some attributes
    ignored_attributes["_self"].each do |attr|
      @master.send(attr.to_sym).should_not == dup_contact_attr[attr]
    end
    # Check that other fields have been merged
    %w(first_name last_name access facebook twitter).each do |attr|
      @master.send(attr.to_sym).should == dup_contact_attr[attr]
    end
  end

  it "should update existing aliases pointing to the duplicate record" do
    @ca1 = ContactAlias.create(:contact => @duplicate,
                               :destroyed_contact_id => 12345)
    @ca2 = ContactAlias.create(:contact => @duplicate,
                               :destroyed_contact_id => 23456)
    @duplicate.merge_with(@master)

    @ca1.reload; @ca2.reload
    @ca1.contact_id.should == @master.id
    @ca2.contact_id.should == @master.id
  end

#  it "should delete any aliases pointing to a record when that record is deleted" do
#    @ca1 = ContactAlias.create(:contact => @duplicate,
#                               :destroyed_contact_id => 12345)
#    @ca2 = ContactAlias.create(:contact => @duplicate,
#                               :destroyed_contact_id => 23456)

#    @duplicate.destroy
#
#    ContactAlias.find_all_by_contact_id(@duplicate.id).should be_empty
#
#  end
end
