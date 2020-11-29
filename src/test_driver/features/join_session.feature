Feature: Join a session as a speaker
    Scenario: when a valid session ID is given
        Given I have "sessionIdField" and "joinSessionButton"
        Then I tap the "joinSessionButton"
        Then I should have "sessionPage" on screen