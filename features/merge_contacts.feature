@javascript
Feature: Merge Contacts
  In order to clean up duplicate contact records
  Users
  want to merge duplicate contacts together

  Scenario: User should be able to merge a contact
    Given a logged in user
    And a contact with full name "George Foreman Grill Expert"
    And a contact with full name "Reginald Harry Junior"
    When I go to the contacts page
    When I move the mouse over "contact_1"
    And I follow "Merge" within "#contact_1"
    And I fill in "auto_complete_query" with "Reginald"
    And I should see "Reginald Harry Junior" within "#auto_complete_dropdown"
    And I click the first autocomplete dropdown option
    And I should see "Duplicate Contact: George Foreman Grill Expert"
    And I should see "Master Contact: Reginald Harry Junior"

