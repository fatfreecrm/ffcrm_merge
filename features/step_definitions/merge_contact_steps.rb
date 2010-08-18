When /^I click the first autocomplete dropdown option$/ do
  begin
    Capybara.current_session.driver.browser.
       execute_script("$$('#auto_complete_dropdown ul li').first().simulate('click');")
  rescue Capybara::NotSupportedByDriverError
  end
end

