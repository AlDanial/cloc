# https://raw.githubusercontent.com/diaspora/diaspora/master/features/mobile/activity_stream.feature
@javascript @mobile
Feature: Viewing my activity on the steam mobile page
  In order to navigate Diaspora*
  As a mobile user
  I want to view my activity stream

  Background:
    Given following users exist:
      | username   |
      | alice      |
      | bob        |
    And a user with username "bob" is connected with "alice"
    And "alice@alice.alice" has a public post with text "Hello! I am #newhere"
             # another comment
  Scenario: Show my activity empty
    When I sign in as "bob@bob.bob" on the mobile website
    When I go to the activity stream page
    Then I should see "My activity" within "#main"
    And I should not see "Hello! I am #newhere"

  Scenario: Show liked post on my activity
    When I sign in as "bob@bob.bob" on the mobile website
    When I click on selector "a.like-action.inactive"
    And I go to the activity stream page
    Then I should see "My activity" within "#main"
    And I should see "Hello! I am #newhere" within ".ltr"

  Scenario: Show own post on my activity
    When I sign in as "alice@alice.alice" on the mobile website
    And I go to the activity stream page
    Then I should see "My activity" within "#main"
    And I should see "Hello! I am #newhere" within ".ltr"
