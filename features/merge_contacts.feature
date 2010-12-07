@javascript
Feature: Merge Contacts
  In order to clean up duplicate contact records
  Users
  want to merge duplicate contacts together

  Scenario: User should be able to merge a contact
    Given a logged in user
    And two duplicate contacts
    When I go to the contacts page
    Then I should see "Test User One" within "#contacts"
    And I should see "Test User Two" within "#contacts"

    When I move the mouse over "contact_1"
    And I follow "Merge" within "#contact_1"
    And I fill in "auto_complete_query" with "Two"
    And I should see "Test User Two" within "#auto_complete_dropdown"
    And I click the first autocomplete dropdown option
    Then I should see "Duplicate Contact: Test User One"
    And I should see "Master Contact: Test User Two"

    When I choose "ignore_email_yes"
    And I choose "ignore_alt_email_no"
    And I choose "ignore_phone_yes"
    And I choose "ignore_mobile_no"
    And I force the confirm dialog to return true
    And I press "Merge Contacts"
    Then I should see "Test User Two" within "#contacts"
    And I should not see "Test User One" within "#contacts"
    When I follow "Test User Two" within "#contacts"
    Then I should see "testusertwo@example.com"
    And I should see "testuserone@test.com"
    And I should see "2222-2222"
    And I should see "(111)1111111111"
    And I should see "Test Task One"
    And I should see "Test Task Two"
    And I should see "Test Opportunity One"
    And I should see "Test Opportunity Two"
    And I should see "Test Email One"
    And I should see "Test Email Two"
    And I should see "Test Comment One"
    And I should see "Test Comment Two"

  Scenario: User should be able to reverse the master and duplicate contacts
    Given a logged in user
    And two duplicate contacts
    And I go to the contacts page
    And I move the mouse over "contact_1"
    And I follow "Merge" within "#contact_1"
    And I fill in "auto_complete_query" with "Two"
    And I should see "Test User Two" within "#auto_complete_dropdown"
    And I click the first autocomplete dropdown option
    Then I should see "Duplicate Contact: Test User One"
    And I should see "Master Contact: Test User Two"

    When I follow "Duplicate <==> Master"
    Then I should see "Duplicate Contact: Test User Two"
    And I should see "Master Contact: Test User One"

    When I choose "ignore_email_yes"
    And I choose "ignore_alt_email_no"
    And I choose "ignore_phone_yes"
    And I choose "ignore_mobile_no"
    And I force the confirm dialog to return true
    And I press "Merge Contacts"
    Then I should see "Test User One" within "#contacts"
    And I should not see "Test User Two" within "#contacts"
    When I follow "Test User One" within "#contacts"
    Then I should see "testuserone@example.com"
    And I should see "testusertwo@test.com"
    And I should see "1111-1111"
    And I should see "(222)2222222222"

  Scenario: A contact should not be able to merge with itself
    Given a logged in user
    And two duplicate contacts
    And I go to the contacts page
    And I move the mouse over "contact_1"
    And I follow "Merge" within "#contact_1"
    And I fill in "auto_complete_query" with "One"
    Then I should see "No contacts match One" within "#auto_complete_dropdown"
    When I fill in "auto_complete_query" with "Two"
    Then I should see "Test User Two" within "#auto_complete_dropdown"
    When I move the mouse over "contact_2"
    And I follow "Merge" within "#contact_2"
    And I fill in "auto_complete_query" with "Test User"
    Then I should see "Test User One" within "#auto_complete_dropdown"
    And I should not see "Test User Two" within "#auto_complete_dropdown"

