@javascript
Feature: Merge Accounts
  In order to clean up duplicate account records
  Users
  want to merge duplicate accounts together

  Scenario: User should be able to merge a account
    Given a logged in user
    And two duplicate accounts
    When I go to the accounts page
    Then I should see "Test Account One" within "#accounts"
    And I should see "Test Account Two" within "#accounts"

    When I move the mouse over "account_1"
    And I follow "Merge" within "#account_1"
    And I fill in "auto_complete_query" with "Two"
    And I should see "Test Account Two" within "#auto_complete_dropdown"
    And I click the first autocomplete dropdown option
    Then I should see "Duplicate Account: Test Account One"
    And I should see "Master Account: Test Account Two"

    When I choose "ignore_email_yes"
    And I choose "ignore_website_no"
    And I choose "ignore_phone_yes"
    And I choose "ignore_fax_no"
    And I force the confirm dialog to return true
    And I press "Merge Accounts"
    Then I should see "Test Account Two" within "#accounts"
    And I should not see "Test Account One" within "#accounts"
    When I follow "Test Account Two" within "#accounts"
    Then I should see "testusertwo@example.com"
    And I should see "testuserone.com"
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
    And I should see "Test Contact One"
    And I should see "Test Contact Two"

  Scenario: User should be able to reverse the master and duplicate accounts
    Given a logged in user
    And two duplicate accounts
    And I go to the accounts page
    And I move the mouse over "account_1"
    And I follow "Merge" within "#account_1"
    And I fill in "auto_complete_query" with "Two"
    And I should see "Test Account Two" within "#auto_complete_dropdown"
    And I click the first autocomplete dropdown option
    Then I should see "Duplicate Account: Test Account One"
    And I should see "Master Account: Test Account Two"

    When I follow "Duplicate <==> Master"
    Then I should see "Duplicate Account: Test Account Two"
    And I should see "Master Account: Test Account One"

    When I choose "ignore_email_yes"
    And I choose "ignore_website_no"
    And I choose "ignore_phone_yes"
    And I choose "ignore_fax_no"
    And I force the confirm dialog to return true
    And I press "Merge Accounts"
    Then I should see "Test Account One" within "#accounts"
    And I should not see "Test Account Two" within "#accounts"
    When I follow "Test Account One" within "#accounts"
    Then I should see "testuserone@example.com"
    And I should see "testusertwo.com"
    And I should see "1111-1111"
    And I should see "(222)2222222222"

  Scenario: A account should not be able to merge with itself
    Given a logged in user
    And two duplicate accounts
    And I go to the accounts page
    And I move the mouse over "account_1"
    And I follow "Merge" within "#account_1"
    And I fill in "auto_complete_query" with "One"
    Then I should see "No accounts match One" within "#auto_complete_dropdown"
    When I fill in "auto_complete_query" with "Two"
    Then I should see "Test Account Two" within "#auto_complete_dropdown"
    When I move the mouse over "account_2"
    And I follow "Merge" within "#account_2"
    And I fill in "auto_complete_query" with "Test Account"
    Then I should see "Test Account One" within "#auto_complete_dropdown"
    And I should not see "Test Account Two" within "#auto_complete_dropdown"

