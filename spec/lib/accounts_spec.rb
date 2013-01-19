require 'spec_helper'

describe Account do
  before :each do
    @master     = FactoryGirl.create(:account,
                           :name            => "Master Name",
                           :email           => "Master Email",
                           :background_info => "Master Background Info")
    @duplicate = FactoryGirl.create(:account,
                           :name            => "Duplicate Name",
                           :email           => "Duplicate Email",
                           :background_info => "Duplicate Background Info")
    2.times do
      FactoryGirl.create(:email, :mediator => @master)
      FactoryGirl.create(:email, :mediator => @duplicate)
      FactoryGirl.create(:comment, :commentable => @master)
      FactoryGirl.create(:comment, :commentable => @duplicate)
    end
  end

  it "should be able to merge itself into another account" do
    # Store the attributes we want to match
    dup_account_attr  = @duplicate.merge_attributes
    dup_has_many_hash = {:emails        => @duplicate.emails.dup,
                         :comments      => @duplicate.comments.dup,
                         :contacts      => @duplicate.contacts.dup,
                         :opportunities => @duplicate.opportunities.dup,
                         :tasks         => @duplicate.tasks.dup}

    @duplicate.merge_with(@master)

    # Check that the duplicate account has been merged
    @master.merge_attributes.should == dup_account_attr
    @master.user.should             == @duplicate.user
    @master.billing_address.should  == @duplicate.billing_address
    @master.shipping_address.should == @duplicate.shipping_address

    # Check that all 'has_many' associations have been transferred
    # from the duplicate to the master.
    dup_has_many_hash.each do |method, collection|
      collection.each do |asset|
        @master.send(method).include?(asset).should == true
      end
    end

    # Duplicate accounts activities should have been destroyed.
    #~ @duplicate.activities.should be_empty

    # Check that the account alias has been created correctly.
    AccountAlias.find_by_destroyed_account_id(@duplicate.id).account.should == @master
  end

  it "should be able to ignore some attributes when merging" do
    ignored_attributes = %w(fax website background_info)

    # Save the attributes we want to match
    dup_account_attr = @duplicate.merge_attributes

    @duplicate.merge_with(@master, ignored_attributes)

    # Check that the duplicate account has ignored some attributes
    ignored_attributes.each do |attr|
      @master.send(attr.to_sym).should_not == dup_account_attr[attr]
    end
    # Check that other fields have been merged
    %w(name email phone toll_free_phone).each do |attr|
      @master.send(attr.to_sym).should == dup_account_attr[attr]
    end
  end

  it "should update existing aliases pointing to the duplicate record" do
    @aa1 = AccountAlias.create(:account => @duplicate,
                               :destroyed_account_id => 12345)
    @aa2 = AccountAlias.create(:account => @duplicate,
                               :destroyed_account_id => 23456)
    @duplicate.merge_with(@master)

    @aa1.reload; @aa2.reload
    @aa1.account_id.should == @master.id
    @aa2.account_id.should == @master.id

  end
end
