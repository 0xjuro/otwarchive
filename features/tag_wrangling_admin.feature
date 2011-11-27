@users @tag_wrangling @admin
Feature: Tag wrangling

  Scenario: Admin can rename a tag

    Given I am logged in as an admin
      And a fandom exists with name: "Amelie", canonical: false
    When I edit the tag "Amelie"
      And I fill in "Synonym of" with "Am�lie"
      And I press "Save changes"
    Then I should see "Am�lie is considered the same as Amelie by the database"
      And I should not see "Tag was successfully updated."
    When I fill in "Name" with "Am�lie"
      And I press "Save changes"
    Then show me the main content
