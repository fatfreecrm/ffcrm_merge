require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Contact do
  before :each do

    @tag_one = Factory(:tag, :taggable_type => "Contact", :name => "TagOne")
    @tag_two = Factory(:tag, :taggable_type => "Contact", :name => "TagTwo")

    @custom_field_one = Customfield.create!(
      :field_name  => "field_one",
      :field_label => "Field One",
      :field_type  => "VARCHAR(255)",
      :user        => Factory(:user),
      :tag         => @tag_one
    )

    @custom_field_two = Customfield.create!(
      :field_name  => "field_two",
      :field_label => "Field Two",
      :field_type  => "VARCHAR(255)",
      :user        => Factory(:user),
      :tag         => @tag_two
    )

    @contact = Factory(:contact,
                       :title  => "Master Contact",
                       :tag_list => @tag_one.name,
                       "tag#{@tag_one.id}_attributes".to_sym => {"field_one" => "test value one"})
  end

  it "should merge different supertags from both records" do
    @dup_contact = Factory(:contact,
                           :title  => "Duplicate Contact",
                           :tag_list => @tag_two.name,
                           "tag#{@tag_two.id}_attributes".to_sym => {"field_two" => "test value two"})

    @dup_contact.merge_with(@contact)

    @contact.reload

    [@tag_one, @tag_two].each do |tag|
      @contact.tags.should include(tag)
    end
    @contact.send("tag#{@tag_one.id}").field_one.should == "test value one"
    @contact.send("tag#{@tag_two.id}").field_two.should == "test value two"
  end

  it "should merge shared supertags with customfields" do
    @dup_contact = Factory(:contact,
                           :title  => "Duplicate Contact",
                           :tag_list => "#{@tag_one.name}, #{@tag_two.name}",
                           "tag#{@tag_one.id}_attributes".to_sym => {"field_one" => "duplicate test value one"},
                           "tag#{@tag_two.id}_attributes".to_sym => {"field_two" => "test value two"}
                           )

    @dup_contact.merge_with(@contact)

    @contact.reload

    @contact.send("tag#{@tag_one.id}").field_one.should == "duplicate test value one"
    @contact.send("tag#{@tag_two.id}").field_two.should == "test value two"
  end

  it "should ignore given attributes when merging shared supertags with customfields" do
    @dup_contact = Factory(:contact,
                           :title  => "Duplicate Contact",
                           :tag_list => "#{@tag_one.name}, #{@tag_two.name}",
                           "tag#{@tag_one.id}_attributes".to_sym => {"field_one" => "duplicate test value one"},
                           "tag#{@tag_two.id}_attributes".to_sym => {"field_two" => "test value two"}
                           )
    ignored_attr = {"tags" => {"tagone" => ["field_one"]}}

    @dup_contact.merge_with(@contact, ignored_attr)

    @contact.reload

    @contact.send("tag#{@tag_one.id}").field_one.should == "test value one"
    @contact.send("tag#{@tag_two.id}").field_two.should == "test value two"
  end

end

