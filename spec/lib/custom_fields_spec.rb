require 'spec_helper'

describe Contact do
  before :each do

    @tag_one = FactoryGirl.create(:tag)
    @tag_two = FactoryGirl.create(:tag)

    @custom_field_one = Customfield.create!(
      :field_name  => "field_one",
      :field_label => "Field One",
      :field_type  => "VARCHAR(255)",
      :user        => FactoryGirl.create(:user),
      :tag         => @tag_one
    )

    @custom_field_two = Customfield.create!(
      :field_name  => "field_two",
      :field_label => "Field Two",
      :field_type  => "VARCHAR(255)",
      :user        => FactoryGirl.create(:user),
      :tag         => @tag_two
    )

    @master = FactoryGirl.create(:contact,
                       :title  => "Master Contact",
                       :tag_list => @tag_one.name,
                       "tag#{@tag_one.id}_attributes".to_sym => {"field_one" => "test value one"})
  end

  it "should merge different custom fields from both records" do
    @duplicate = FactoryGirl.create(:contact,
                           :title  => "Duplicate Contact",
                           :tag_list => @tag_two.name,
                           "tag#{@tag_two.id}_attributes".to_sym => {"field_two" => "test value two"})

    @duplicate.merge_with(@master)

    @master.reload

    [@tag_one, @tag_two].each do |tag|
      @master.tags.should include(tag)
    end
    @master.send("tag#{@tag_one.id}").field_one.should == "test value one"
    @master.send("tag#{@tag_two.id}").field_two.should == "test value two"
  end

  it "should merge shared custom fields with customfields" do
    @duplicate = FactoryGirl.create(:contact,
                           :title  => "Duplicate Contact",
                           :tag_list => "#{@tag_one.name}, #{@tag_two.name}",
                           "tag#{@tag_one.id}_attributes".to_sym => {"field_one" => "duplicate test value one"},
                           "tag#{@tag_two.id}_attributes".to_sym => {"field_two" => "test value two"}
                           )

    @duplicate.merge_with(@master)

    @master.reload

    @master.send("tag#{@tag_one.id}").field_one.should == "duplicate test value one"
    @master.send("tag#{@tag_two.id}").field_two.should == "test value two"
  end

  it "should ignore given attributes when merging shared custom fields with customfields" do
    @duplicate = FactoryGirl.create(:contact,
                           :title  => "Duplicate Contact",
                           :tag_list => "#{@tag_one.name}, #{@tag_two.name}",
                           "tag#{@tag_one.id}_attributes".to_sym => {"field_one" => "duplicate test value one"},
                           "tag#{@tag_two.id}_attributes".to_sym => {"field_two" => "test value two"}
                           )
    ignored_attr = {"tags" => {"tagone" => ["field_one"]}}

    @duplicate.merge_with(@master, ignored_attr)

    @master.reload

    @master.send("tag#{@tag_one.id}").field_one.should == "test value one"
    @master.send("tag#{@tag_two.id}").field_two.should == "test value two"
  end

end
