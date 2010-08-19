@javascript
Feature: Merge Contacts
  In order to clean up duplicate contact records
  Users
  want to merge duplicate contacts together

  Scenario: User should be able to merge a contact
    Given a logged in user
    And two duplicate contacts
    When I go to the contacts page
    Then I should see "Test User One"
    And I should see "Test User Two"

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
    Then I should see "Test User Two"
    And I should not see "Test User One"
    When I follow "Test User Two"
    Then I should see "testusertwo@example.com"
    And I should see "testuserone@test.com"
    And I should see "2222-2222"
    And I should see "(111)1111111111"

