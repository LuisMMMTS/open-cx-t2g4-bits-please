# open-cx-t2g4 Com4All

![test](https://github.com/FEUP-ESOF-2020-21/open-cx-t2g4-bits-please/workflows/test/badge.svg)

Welcome to the documentation pages of the *Com4All* of **openCX**!

You can find here detailed about the (sub)product, hereby mentioned as module, from a high-level vision to low-level implementation decisions, a kind of Software Development Report (see [template](https://github.com/softeng-feup/open-cx/blob/master/docs/templates/Development-Report.md)), organized by discipline (as of RUP): 

* Business modeling 
  * [Product Vision](#Product-Vision)
  * [Elevator Pitch](#Elevator-Pitch)
* Requirements
  * [Use Case Diagram](#Use-case-diagram)
  * [User stories](#User-stories)
  * [Domain model](#Domain-model)
* Architecture and Design
  * [Logical architecture](#Logical-architecture)
  * [Physical architecture](#Physical-architecture)
  * [Prototype](#Prototype)
* [Implementation](#Implementation)
* [Test](#Test)
* [Configuration and change management](#Configuration-and-change-management)
* [Project management](#Project-management)

So far, contributions are exclusively made by the initial team, but we hope to open them to the community, in all areas and topics: requirements, technologies, development, experimentation, testing, etc.

Please contact us! 

Thank you!

Breno Pimentel  
Diogo Rodrigues  
L. Miguel Pinto  
Nuno Oliveira  

---

## Product Vision
Bring everyone to the conference sessions! Let the deaf hear and the mute speak.

---
## Elevator Pitch
In every conference there are two main elements: to listen and to see. But the former is not always possible due to hearing loss.  
The interaction between the audience and the speaker makes conferences alive, that's why whe created **Com4All**.

The **Com4All** is an app that enables communication, allowing one to keep track of the session through a real-time transcription of what is being said.  

This solution's main advantages are that it is free and open-source, in addiction to being simple, fast, and light resource- and data-wise.

---
## Requirements

### Use case diagram 

![Use Cases](images/use-cases.svg)

#### Get talk transcript:
*  **Actor**. Attendee
*  **Description**. With this use case the attendee can follow and understand the speaker by reading the transcript of the talk.
*  **Preconditions and Postconditions**.  The attendee must have a valid profile and access to the conference. Then he can read the transcript of the speaker in the application.
*  **Normal Flow**. 
	1. The attendee selects the conference.
	2. The attendee reads the transcript with his phone.
	3. If the user desires, he can save and read the transcript afterwards.
*  **Alternative Flows and Exceptions**. 
	1. The attendee selects the conference.
	2. The attendee reads the transcript with his phone.
	3. The transcript do not load properly a warning pops up.
	4. The application is not able to transcript the audio a warning pops up.
    * **OR**
    1. The attendee selects the conference.
    2. If he does not have the access in this meeting, a warning pops up.

#### Submit question:
* **Actor:** Attendee
* **Description:** This use case exists so the attendee can submit questions to the speaker  
* **Preconditions and Postconditions:** In order to submit a question the attendee must be logged in and signed in a specific talk  
* **Normal Flow:**
  1. The attendee writes the question to the speaker and presses the button.
  2. The system stores the question on the server.
* **Alternative Flows and Exceptions:**
  1. The attendee writes the question to the speaker and presses the button.
  2. If the system can't connect to the server, a warning pops up system informs the attendee of the error

#### Manage profile:
* **Actor:** User
* **Description:** This use case exists so the user can see and manage his/her profile settings.
* **Preconditions and Postconditions:** In order to see his/her profile the user must be logged in.  
* **Normal Flow:**
  1. The user opens the profile settings.
  2. The user sees the profile settings.
  3. The user exits the profile settings.
  * **OR**
  1. The user opens the profile settings.
  2. The user changes one of the settings.
  3. The user saves the settings, sending them to the server.
  4. The user exits the profile settings.
* **Alternative Flows and Exceptions:**
  1. The user opens the profile settings.
  2. The user changes one of the settings.
  3. The user saves the settings, but if the device has no Internet connection a warning pops up.

#### Get question:
*  **Actor**. Speaker.
*  **Description**. This use case consists of receiving the question from a member of the audience in the database and converting it to speech (normally).
*  **Preconditions and Postconditions**. In order for this to happen, the speaker must be logged in talk's page. In the end, he can choose to simply read the question or have it be converted to speech.
*  **Normal Flow**. 
	1. The speaker is logged in.
	2. He gets a question and chooses to synthesize it.
	3. The audio corresponding to the question will play.
*  **Alternative Flows and Exceptions**. 
	1. The speaker gets a question and chooses not to synthesize it.
	* **OR**
	1. The speaker has some problem in his connection and a warning pops-up.
	
#### Submit talk transcript:
* **Actor**. Speaker
* **Description**. This use case exists so that the speaker's voice can be recorded, converted to text and the transcript uploaded to the database for the audience to read it.
* **Preconditions and Postconditions**. To have his voice transcribed, the speaker must be logged in, be in the talk's page, and have a working microphone. In the end, the speaker's voice transcript is added to the database.
* **Normal flow**.
    1. The speaker presses the button to start transcribing and uploading.
    2. The speaker gives the talk
    3. The speaker presses the button again to stop transcribing and uploading.
* **Alternative Flows and Exceptions**.
    1. The speaker presses the button to start transcribing and uploading.
    2. If the speaker has not spoken for some time, he is prompted to confirm he's still in a talk.
    3. If the speaker does not answer, or cancels, recording is stopped.
    4. If the speaker confirms, the recording continues as usual.
    * **OR**
    1. The speaker presses the button to start transcribing and uploading.
    2. If there is no Internet connection, or the connection drops, a warning pops up.

### User stories

**Must have**:
- [transcribe](#Story-"transcribe")
- [submit-question](#Story-"submit-question")
- [synthesize-question](#Story-"synthesize-question")

**Should have**:
- [delete-question](#Story-"delete-question")
- [accept-question](#Story-"accept-question")

**Could have**:
- [resize-transcript](#Story-"resize-transcript")
- [dark-mode](#Story-"dark-mode")
- [change-display-name](#Story-"change-display-name")
- [notes](#Story-"notes")
- [translate-transcript](#Story-"translate-transcript")


#### Story "transcribe"

As a speaker, I want my speech to be transcribed and sent to the attendees, so they can hear me

##### User interface mockup

![transcribe mockup](https://drive.google.com/uc?id=1j7mHZ7WRvmdQKRnBWeUk1Qw9THBV-aRh)

##### Description
- The speaker has to authenticate to a session (through its session ID) using his authentication code (which is a short string like 1234)
- The speaker can leave the session chat by pressing the exit button on the top left.

##### Acceptance Tests
```Gherkin
Scenario: Transcribing speech  
	When I press the record button
  And I say "Hello world"
	Then "Hello world" is sent to all attendees  
```
	
##### Value and Effort
Value:  Must-Have  
Effort: XL  

#### Story "submit-question"

As a conference attendee who can't speak, I want to be able to easily submit text questions to the speaker, so I can better understand the talk subjects

##### User interface mockup

![submit-question mockup](https://drive.google.com/uc?id=1CSig6DhVvpL8M3Xk3ZDL7KYVk9Gcfsea)

##### Acceptance Tests
```Gherkin
Scenario: Asking a question  
	When I write the question  
	And I press the submit button  
	Then The server must put my question on the queue  
```
	
##### Value and Effort
Value:  Must-Have  
Effort: XL  

#### Story "synthesize-question"
As the speaker I want to select a specific question and have it synthesized

##### User interface mockup
![synthesize-question mockup](https://drive.google.com/uc?id=1h_kINEZhL4pEvR7Mrm3e_MiVTrl0BRfa)

##### Acceptance tests
```gherkin
Scenario: Synthesizing a question
  When there are X unanswered questions
  And the speaker chooses a question to synthesize
  Then question is indeed synthesized and audio is played
```

##### Value and effort
Value: Must Have
Effort: XL

#### Story "delete-question"
As the speaker I want to delete a question after it has been answered (or not)

##### User interface mockup
![delete-question mockup](https://drive.google.com/uc?id=1nhUYwJ_Q2BNLWo54VLI9i4Ofn4lpJqzo)

##### Acceptance tests
```gherkin
Scenario: Deleting a question
  When there is a question the speaker wants to delete for any reason
  And the speaker chooses to delete the question
  Then question is removed from the database
```

**Value and effort**
Value: Must Have
Effort: XL

#### Story "resize-transcript"

As a user of the application, I want to change the height of the transcript/questions sections so I can read all questions, or focus on the transcript.

##### User interface mockup

![resize-transcript mockup](https://drive.google.com/uc?id=1pvOCQeHWYBiCXJxbWlEVTRa_s0J-SK7U)

##### Acceptance tests
```gherkin
Scenario: Attending in a conference
  When I drag the transcript/separation up or down
  Then The separation moves up and down
  And  The sections are resized accordingly
```

##### Value and Effort
Value:  Should have  
Effort: S

#### Story "accept-question"

As a speaker, I want to be able to notify my audience on whether I will answer a question or not.

##### User interface mockup

![accept-question mockup](https://drive.google.com/uc?id=1ZxM-Z5XQ1IT4P6-aA_TP5PL04Tr3xzsF)

##### Acceptance tests
```gherkin
Scenario: Accept question
  When I tap the check mark of question "Hello, I have a question"
  Then The background of question "Hello, I have a question" changes to green
Scenario: Reject question
  When I tap the cross mark of question "Hello, I have a question"
  Then The background of question "Hello, I have a question" changes to red
```

##### Value and Effort
Value: Should have  
Effort: L

#### Story "dark-mode"

As a user in a conference, I want to be able to change the app theme to dark mode.

##### User interface mockup

![dark-mode mockup](https://drive.google.com/uc?id=17JEJ0TqoxT54AIzR2BD8lx0OMkC4QTSF)

##### Acceptance tests
```gherkin
Scenario: Enable dark mode
  When I enable dark mode
  Then the app shows in dark mode
  And  dark mode persists
```

##### Value and Effort
Value:  Should have  
Effort: M

#### Story "change-display-name"

As a user in a conference, I want to be able to change my Display Name so others can more easily recognize me or so I am showing my favorite name.

##### User interface mockup

![change-display-name mockup](https://drive.google.com/uc?id=16A8k2s2MnJg05RYD4GFSORa1E0g2mbKL)

##### Acceptance tests
```gherkin
Scenario: Change display name
  When I edit my display name
  And  I press the save button
  Then My display name is saved in my device
  And  My display name is updated in the server
```

##### Value and Effort
Value:  Could have  
Effort: M

#### Story "notes"

As an attendee in a conference, I want to be able to take notes and highlights of the speaker presentation in my device so that I can search than later.

##### User interface mockup

![notes mockup](https://drive.google.com/uc?id=1wkRdit9D9B2Zl08_HB_ktNJzS5ekVTbL)

##### Acceptance tests
```gherkin
Scenario: Taking notes in the conference
  When I write my note or highlighted part of the transcription
  And I press the save button
  Then The text is marked and I can consult it later
```

##### Value and Effort
Value:  Could have  
Effort: S

#### Story "translate-transcript"

As an attendee in a conference, I want to understand what is being said even if I don't know the speaker's language.

##### User interface mockup

TODO

##### Acceptance tests
```gherkin
Scenario: Attending in a conference
  When I can't speak the language spoken
  And  I select the language I want to be transcribed
  Then I get the transcript with my language of choice
```

##### Value and Effort
Value:  Could have  
Effort: M

### Domain model

To better understand the context of the software system, it is very useful to have a simple UML class diagram with all the key concepts (names, attributes) and relationships involved of the problem domain addressed by your module.

---

## Architecture and Design
The architecture of a software system encompasses the set of key decisions about its overall organization. 

A well written architecture document is brief but reduces the amount of time it takes new programmers to a project to understand the code to feel able to make modifications and enhancements.

To document the architecture requires describing the decomposition of the system in their parts (high-level components) and the key behaviors and collaborations between them. 

In this section you should start by briefly describing the overall components of the project and their interrelations. You should also describe how you solved typical problems you may have encountered, pointing to well-known architectural and design patterns, if applicable.

### Logical architecture
The purpose of this subsection is to document the high-level logical structure of the code, using a UML diagram with logical packages, without the worry of allocating to components, processes or machines.

It can be beneficial to present the system both in a horizontal or vertical decomposition:
* horizontal decomposition may define layers and implementation concepts, such as the user interface, business logic and concepts; 
* vertical decomposition can define a hierarchy of subsystems that cover all layers of implementation.

### Physical architecture

![Physical architecture](https://drive.google.com/uc?id=1rgcc0jQ3XAd2BTVOjhjPFrYSpomnKoAa)

The goal of this subsection is to document the high-level physical structure of the software system (machines, connections, software components installed, and their dependencies) using UML deployment diagrams or component diagrams (separate or integrated), showing the physical structure of the system.

It should describe also the technologies considered and justify the selections made. Examples of technologies relevant for openCX are, for example, frameworks for mobile applications (Flutter vs ReactNative vs ...), languages to program with microbit, and communication with things (beacons, sensors, etc.).

### Prototype
To help on validating all the architectural, design and technological decisions made, we usually implement a vertical prototype, a thin vertical slice of the system.

In this subsection please describe in more detail which, and how, user(s) story(ies) were implemented.

---

## Implementation

Changelogs for the 4 different product increments can be found [here](https://github.com/FEUP-ESOF-2020-21/open-cx-t2g4-bits-please/releases)

---
## Test

To ensure the quality of the application, we performed automated tests with Flutter Gherkin.

The features tested are:
* [Joining a session](https://github.com/FEUP-ESOF-2020-21/open-cx-t2g4-bits-please/blob/main/src/test_driver/features/join_session.feature)
* [Asking a question](https://github.com/FEUP-ESOF-2020-21/open-cx-t2g4-bits-please/blob/main/src/test_driver/features/ask_question.feature)

In this section it is only expected to include the following:
* test plan describing the list of features to be tested and the testing methods and tools;
* test case specifications to verify the functionalities, using unit tests and acceptance tests.
 
A good practice is to simplify this, avoiding repetitions, and automating the testing actions as much as possible.

---
## Configuration and change management

Configuration and change management are key activities to control change to, and maintain the integrity of, a project’s artifacts (code, models, documents).

For the purpose of ESOF, we will use a very simple approach, just to manage feature requests, bug fixes, and improvements, using GitHub issues and following the [GitHub flow](https://guides.github.com/introduction/flow/).


---

## Project management

Software project management is an art and science of planning and leading software projects, in which software projects are planned, implemented, monitored and controlled.

In the context of ESOF, we expect that each team adopts a project management tool capable of registering tasks, assign tasks to people, add estimations to tasks, monitor tasks progress, and therefore being able to track their projects.

Example of tools to do this are:
  * [Trello.com](https://trello.com)
  * [Github Projects](https://github.com/features/project-management/com)
  * [Pivotal Tracker](https://www.pivotaltracker.com)
  * [Jira](https://www.atlassian.com/software/jira)

We recommend to use the simplest tool that can possibly work for the team.


---

## Evolution - contributions to open-cx

Describe your contribution to open-cx (iteration 5), linking to the appropriate pull requests, issues, documentation.
