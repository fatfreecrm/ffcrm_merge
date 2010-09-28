Given /^two duplicate contacts$/ do
  @dup_contact = Factory(:contact, :first_name => "Test User",
                                   :last_name  => "One",
                                   :phone      => "1111-1111",
                                   :mobile     => "(111)1111111111",
                                   :email      => "testuserone@example.com",
                                   :alt_email  => "testuserone@test.com")

  @tasks = %w(One Two).map {|n| Factory(:task,   :asset => @dup_contact,
                                                 :name  => "Test Task #{n}")}

  @emails = %w(One Two).map {|n| Factory(:email, :mediator => @dup_contact,
                                                 :subject  => "Test Email #{n}")}

  @opportunities = %w(One Two).map {|n| Factory(:contact_opportunity,
                                                :contact => @dup_contact,
                            :opportunity => Factory(:opportunity,
                                                    :name => "Test Opportunity #{n}",
                                                    :account => Factory(:account)))}

  @contact     = Factory(:contact, :first_name => "Test User",
                                   :last_name  => "Two",
                                   :phone      => "2222-2222",
                                   :mobile     => "(222)2222222222",
                                   :email      => "testusertwo@example.com",
                                   :alt_email  => "testusertwo@test.com")
end

When /^I click the first autocomplete dropdown option$/ do
  begin
    Capybara.current_session.driver.browser.
       execute_script("$$('#auto_complete_dropdown ul li').first().simulate('click');")
  rescue Capybara::NotSupportedByDriverError
  end
end

When /^I force the confirm dialog to return true$/ do
  begin
    Capybara.current_session.driver.browser.
       execute_script("window.confirm = function() { return true; }")
  rescue Capybara::NotSupportedByDriverError
  end
end

