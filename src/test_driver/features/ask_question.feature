Feature: Asking a question
    Scenario: Asking a question  
	    When I write the question "Can you read this question?"
	    And I press the "submitButton"  
	    Then The server must put my question "Can you read this question?" on the queue