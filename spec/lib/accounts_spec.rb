require 'spec_helper'

describe Account do
  before :each do
    @account     = FactoryGirl.create(:account,
                           :name            => "Master Name",
                           :email           => "Master Email",
                           :background_info => "Master Background Info")
    @dup_account = FactoryGirl.create(:account,
                           :name            => "Duplicate Name",
                           :email           => "Duplicate Email",
                           :background_info => "Duplicate Background Info")
    4.times do
      FactoryGirl.create(:email, :mediator => @account)
      FactoryGirl.create(:email, :mediator => @dup_account)
      FactoryGirl.create(:comment, :commentable => @account)
      FactoryGirl.create(:comment, :commentable => @dup_account)
    end
  end

  it "should be able to merge itself into another account" do
    # Store the attributes we want to match
    dup_account_attr  = @dup_account.merge_attributes
    dup_has_many_hash = {:emails        => @dup_account.emails.dup,
                         :comments      => @dup_account.comments.dup,
                         :contacts      => @dup_account.contacts.dup,
                         :opportunities => @dup_account.opportunities.dup,
                         :tasks         => @dup_account.tasks.dup}

    @dup_account.merge_with(@account)

    # Check that the duplicate account has been merged
    @account.merge_attributes.should == dup_account_attr
    @account.user.should             == @dup_account.user
    @account.billing_address.should  == @dup_account.billing_address
    @account.shipping_address.should == @dup_account.shipping_address

    # Check that all 'has_many' associations have been transferred
    # from the duplicate to the master.
    dup_has_many_hash.each do |method, collection|
      collection.each do |asset|
        @account.send(method).include?(asset).should == true
      end
    end

    # Duplicate accounts activities should have been destroyed.
    #~ @dup_account.activities.should be_empty

    # Check that the account alias has been created correctly.
    AccountAlias.find_by_destroyed_account_id(@dup_account.id).account.should == @account
  end

  it "should be able to ignore some attributes when merging" do
    ignored_attributes = %w(fax website background_info)

    # Save the attributes we want to match
    dup_account_attr = @dup_account.merge_attributes

    @dup_account.merge_with(@account, ignored_attributes)

    # Check that the duplicate account has ignored some attributes
    ignored_attributes.each do |attr|
      @account.send(attr.to_sym).should_not == dup_account_attr[attr]
    end
    # Check that other fields have been merged
    %w(name email phone toll_free_phone).each do |attr|
      @account.send(attr.to_sym).should == dup_account_attr[attr]
    end
  end

  it "should update existing aliases pointing to the duplicate record" do
    @aa1 = AccountAlias.create(:account => @dup_account,
                               :destroyed_account_id => 12345)
    @aa2 = AccountAlias.create(:account => @dup_account,
                               :destroyed_account_id => 23456)
    @dup_account.merge_with(@account)

    @aa1.reload; @aa2.reload
    @aa1.account_id.should == @account.id
    @aa2.account_id.should == @account.id

  end
end
