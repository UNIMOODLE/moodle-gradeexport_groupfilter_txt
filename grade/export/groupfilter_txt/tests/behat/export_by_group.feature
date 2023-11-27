@gradeexport @groupfilter_txt
Feature: I need to export grades as text and ordered by groups
  In order to easily review marks
  As a teacher
  I need to have a export grades as text ordered by groups

  Background:
    Given the following "courses" exist:
      | fullname | shortname | category | groupmode |
      | Course 1 | C1        | 0        | 0         |
    #groupmode -> 0 = No groups
    #groupmode -> 1 = Separated groups
    #groupmode -> 2 = Visible groups
    And the following "users" exist:
      | username | firstname | lastname | email |
      | teacher1 | Teacher | 1 | teacher1@example.com |
    And the following "course enrolments" exist:
      | user | course | role |
      | teacher1 | C1 | editingteacher |
    And the following "activities" exist:
      | activity | course | idnumber | name        | intro | assignsubmission_onlinetext_enabled |
      | assign   | C1     | a1       | Assigment 1 | Submit your online text | 1 |
    And the following "grade categories" exist:
      | fullname | course |
      | Grade Category | C1 |
    And the following "grade items" exist:
      | itemname      | course | category         |
      | Grade Item    | C1     | ?                |
      | Grade Item 2  | C1     | Grade Category   |
    And the following "groups" exist:
      | name    | course | idnumber |
      | Group 1 | C1     | G1       |
      | Group 2 | C1     | G2       |

    And I log in as "teacher1"
    And I am on "Course 1" course homepage

  @javascript @export_users_from_different_groups
  Scenario: Export grades as text file with two users from diferent groups
    Given the following "users" exist:
      | username | firstname | lastname | email |
      | student1 | Student | 1 | student1@example.com |
      | student2 | Student | 2 | student2@example.com |
    And the following "course enrolments" exist:
      | user | course | role |
      | student1 | C1 | student |
      | student2 | C1 | student |
    And the following "group members" exist:
      | user        | group |
      | student1    | G1  |
      | student2    | G2  |
    And I navigate to "View > Grader report" in the course gradebook
    And I turn editing mode on
    And I change window size to "large"
    And I give the grade "10.00" to the user "Student 1" for the grade item "Assigment 1"
    And I give the grade "20.00" to the user "Student 1" for the grade item "Grade Item"
    And I give the grade "30.00" to the user "Student 1" for the grade item "Grade Item 2"
    And I give the grade "10.00" to the user "Student 2" for the grade item "Assigment 1"
    And I give the grade "30.00" to the user "Student 2" for the grade item "Grade Item"
    And I give the grade "40.00" to the user "Student 2" for the grade item "Grade Item 2"
    And I press "Save changes"

    When I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And I set the field "Grade export decimal places" to "1"
    And I press "Download"
    Then I should see "Group 1"
    And I should see "Student"
    And I should see "Assigment 1"
    And I should see "10.0"
    And I should see "Grade Item"
    And I should see "20.0"
    And I should see "Grade Item 2"
    And I should see "30.0"
    And I should see "Grade Category total"
    And I should see "30.0"
    Then I should see "Group 2"
    And I should see "Student"
    And I should see "Assigment 1"
    And I should see "10.0"
    And I should see "Grade Item"
    And I should see "30.0"
    And I should see "Grade Item 2"
    And I should see "40.0"
    And I should see "Grade Category total"
    And I should see "40.0"

  @javascript @export_user_rolled_in_different_groups
  Scenario: Export grades as text file with a user rolled in diferent groups
    Given the following "users" exist:
      | username | firstname | lastname | email |
      | student3 | Student | 3 | student3@example.com |
    And the following "course enrolments" exist:
      | user | course | role |
      | student3 | C1 | student |
    And the following "group members" exist:
      | user        | group |
      | student3    | G1  |
      | student3    | G2  |
    And I navigate to "View > Grader report" in the course gradebook
    And I turn editing mode on
    And I change window size to "large"
    And I give the grade "60.00" to the user "Student 3" for the grade item "Assigment 1"
    And I give the grade "70.00" to the user "Student 3" for the grade item "Grade Item"
    And I give the grade "80.00" to the user "Student 3" for the grade item "Grade Item 2"
    And I press "Save changes"
    When I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And I set the field "Grade export decimal places" to "1"
    And I press "Download"
    Then I should see "Group 1"
    And I should see "Student"
    And I should see "Assigment 1"
    And I should see "60.0"
    And I should see "Grade Item"
    And I should see "70.0"
    And I should see "Grade Item 2"
    And I should see "80.0"
    And I should see "Grade Category total"
    And I should see "80.0"
    Then I should see "Group 2"
    And I should see "Student"
    And I should see "Assigment 1"
    And I should see "60.0"
    And I should see "Grade Item"
    And I should see "70.0"
    And I should see "Grade Item 2"
    And I should see "80.0"
    And I should see "Grade Category total"
    And I should see "80.0"

  @javascript @export_with_no_user_rolled_in_group
  Scenario: Export grades as text file with a user not roled in any group
    Given the following "users" exist:
      | username | firstname | lastname | email |
      | student4 | Student | 4 | student4@example.com |
    And the following "course enrolments" exist:
      | user | course | role |
      | student4 | C1 | student |
    And I navigate to "View > Grader report" in the course gradebook
    And I turn editing mode on
    And I change window size to "large"
    And I give the grade "50.00" to the user "Student 4" for the grade item "Assigment 1"
    And I give the grade "70.00" to the user "Student 4" for the grade item "Grade Item"
    And I give the grade "90.00" to the user "Student 4" for the grade item "Grade Item 2"
    And I press "Save changes"
    When I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And I set the field "Grade export decimal places" to "1"
    And I press "Download"
    Then I should not see "Group 1"
    And I should not see "Group 2"
    And I should see "Student"
    And I should see "Assigment 1"
    And I should see "50.0"
    And I should see "Grade Item"
    And I should see "70.0"
    And I should see "Grade Item 2"
    And I should see "90.0"
    And I should see "Grade Category total"
    And I should see "90.0"




  @javascript @export_without_profield_fields
  Scenario: Export grades as text without user profield fields selected
    Given the following "users" exist:
      | username | firstname | lastname | email |
      | student1 | Student_name | Student_lastname | student1@example.com |
    And the following "course enrolments" exist:
      | user | course | role |
      | student1 | C1 | student |
    And the following "group members" exist:
      | user        | group |
      | student1    | G1  |
    And I navigate to "View > Grader report" in the course gradebook
    And I turn editing mode on
    And I change window size to "large"
    And I give the grade "50.00" to the user "Student_name Student_lastname" for the grade item "Assigment 1"
    And I give the grade "80.00" to the user "Student_name Student_lastname" for the grade item "Grade Item"
    And I give the grade "30.00" to the user "Student_name Student_lastname" for the grade item "Grade Item 2"
    And I press "Save changes"

    When I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And  I set the following fields to these values:
      | First name   | 0                        |
      | Last name    | 0                        |
      | ID number    | 0                        |
      | Institution  | 0                        |
      | Department   | 0                        |
      | Email address| 0                        |
    And I press "Download"

    Then I should see "Group 1"
    And I should see "Assigment 1"
    And I should see "50.0"
    And I should see "Grade Item"
    And I should see "80.0"
    And I should see "Grade Item 2"
    And I should see "30.0"
    And I should see "Grade Category total"
    And I should see "30.0"

  @javascript @export_selecting_some_user_profield_fields
  Scenario: Export grades as text selecting some user profield fields
    Given the following "users" exist:
      | username | firstname | lastname | email |
      | student1 | Student_name | Student_lastname | student1@example.com |
    And the following "course enrolments" exist:
      | user | course | role |
      | student1 | C1 | student |
    And the following "group members" exist:
      | user        | group |
      | student1    | G1  |
    And I navigate to "View > Grader report" in the course gradebook
    And I turn editing mode on
    And I change window size to "large"
    And I give the grade "50.00" to the user "Student_name Student_lastname" for the grade item "Assigment 1"
    And I give the grade "80.00" to the user "Student_name Student_lastname" for the grade item "Grade Item"
    And I give the grade "30.00" to the user "Student_name Student_lastname" for the grade item "Grade Item 2"
    And I press "Save changes"

    When I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And  I set the following fields to these values:
      | First name   | 1                        |
      | Last name    | 1                        |
      | ID number    | 0                        |
      | Institution  | 0                        |
      | Department   | 0                        |
      | Email address| 1                        |
    And I press "Download"

    Then I should see "Group 1"
    And I should see "Student_name"
    And I should see "Student_lastname"
    And I should see "student1@example.com"

    And I should see "Assigment 1"
    And I should see "50.0"
    And I should see "Grade Item"
    And I should see "80.0"
    And I should see "Grade Item 2"
    And I should see "30.0"
    And I should see "Grade Category total"
    And I should see "30.0"

  @javascript @export_user_profield_with_no_rolling_in_groups
  Scenario: Export grades as text selecting some user profield fields without being roled in a group
    Given the following "users" exist:
      | username | firstname | lastname | email |
      | student1 | Student_name | Student_lastname | student1@example.com |
    And the following "course enrolments" exist:
      | user | course | role |
      | student1 | C1 | student |
    And I navigate to "View > Grader report" in the course gradebook
    And I turn editing mode on
    And I change window size to "large"
    And I give the grade "50.00" to the user "Student_name Student_lastname" for the grade item "Assigment 1"
    And I give the grade "70.00" to the user "Student_name Student_lastname" for the grade item "Grade Item"
    And I give the grade "80.00" to the user "Student_name Student_lastname" for the grade item "Grade Item 2"
    And I press "Save changes"

    When I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And  I set the following fields to these values:
      | First name   | 1                        |
      | Last name    | 1                        |
      | ID number    | 0                        |
      | Institution  | 0                        |
      | Department   | 0                        |
      | Email address| 1                        |
    And I press "Download"

    Then I should see ""
    And I should see "Student_name"
    And I should see "Student_lastname"
    And I should see "student1@example.com"

    And I should see "Assigment 1"
    And I should see "50.0"
    And I should see "Grade Item"
    And I should see "70.0"
    And I should see "Grade Item 2"
    And I should see "80.0"
    And I should see "Grade Category total"
    And I should see "80.0"


  @javascript @export_user_all_user_profield_fields
  Scenario: Export grades as text selecting all user profield fields
    Given the following "users" exist:
      | username | firstname | lastname | email | institution | department |
      | student1 | Student_name | Student_lastname | student1@example.com | Universidad Politecnica | Maths |
    And the following "course enrolments" exist:
      | user | course | role |
      | student1 | C1 | student |
    And the following "group members" exist:
      | user        | group |
      | student1    | G1  |
    And I navigate to "View > Grader report" in the course gradebook
    And I turn editing mode on
    And I change window size to "large"
    And I give the grade "50.00" to the user "Student_name Student_lastname" for the grade item "Assigment 1"
    And I give the grade "80.00" to the user "Student_name Student_lastname" for the grade item "Grade Item"
    And I give the grade "30.00" to the user "Student_name Student_lastname" for the grade item "Grade Item 2"
    And I press "Save changes"

    When I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And  I set the following fields to these values:
      | First name   | 1                        |
      | Last name    | 1                        |
      | ID number    | 1                        |
      | Institution  | 1                        |
      | Department   | 1                        |
      | Email address| 1                        |
    And I press "Download"

    Then I should see "Group 1"
    And I should see "Student_name"
    And I should see "Student_lastname"
    And I should see "student1@example.com"
    And I should see "Universidad Politecnica"
    And I should see "Maths"

    And I should see "Assigment 1"
    And I should see "50.0"
    And I should see "Grade Item"
    And I should see "80.0"
    And I should see "Grade Item 2"
    And I should see "30.0"
    And I should see "Grade Category total"
    And I should see "30.0"

  @javascript @export_user_custom_fields_rolled_in_group
  Scenario: Export grades as text using user custom fields with user being rolled in a group
    Given the following "users" exist:
      | username | firstname | lastname | email |
      | student1 | Student_name | Student_lastname | student1@example.com |
    And the following "course enrolments" exist:
      | user | course | role |
      | student1 | C1 | student |
    And the following "group members" exist:
      | user        | group |
      | student1    | G1  |
    And I navigate to "View > Grader report" in the course gradebook
    And I turn editing mode on
    And I change window size to "large"
    And I give the grade "50.00" to the user "Student_name Student_lastname" for the grade item "Assigment 1"
    And I give the grade "80.00" to the user "Student_name Student_lastname" for the grade item "Grade Item"
    And I give the grade "30.00" to the user "Student_name Student_lastname" for the grade item "Grade Item 2"
    And I press "Save changes"

    Then I log in as "admin"
    And I navigate to "Users > Accounts > User profile fields" in site administration
    And I click on "Create a new profile field" "link"
    And I click on "Text area" "link"
    And I set the following fields to these values:
      | Short name                    | Description  |
      | Name                          | Description |
      | Default value                 | Trainee Student |
    When I click on "Save changes" "button"
    Then I should see "Description"
    Then I navigate to "Grades > General settings" in site administration
    And I set the field "Grade export custom profile fields" to "Description"
    And I click on "Save changes" "button"
    And I log out

    And I log in as "teacher1"
    And I am on "Course 1" course homepage
    And I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And  I set the following fields to these values:
      | First name   | 1                        |
      | Last name    | 1                        |
      | ID number    | 1                        |
      | Description  | 1                        |
    And I press "Download"

    Then I should see "Group 1"
    And I should see "Student_name"
    And I should see "Student_lastname"
    And I should see "Description"
    And I should see "Trainee Student"

    And I should see "Assigment 1"
    And I should see "50.0"
    And I should see "Grade Item"
    And I should see "80.0"
    And I should see "Grade Item 2"
    And I should see "30.0"
    And I should see "Grade Category total"
    And I should see "30.0"

  @javascript @export_user_profield_fields_rolled_in_group
  Scenario: Export grades as text adding a user profield field with user being rolled in a group
    Given the following "users" exist:
      | username | firstname | lastname | email | address |
      | student1 | Student_name | Student_lastname | student1@example.com | Wall Street |
    And the following "course enrolments" exist:
      | user | course | role |
      | student1 | C1 | student |
    And the following "group members" exist:
      | user        | group |
      | student1    | G1  |
    And I navigate to "View > Grader report" in the course gradebook
    And I turn editing mode on
    And I change window size to "large"
    And I give the grade "50.00" to the user "Student_name Student_lastname" for the grade item "Assigment 1"
    And I give the grade "80.00" to the user "Student_name Student_lastname" for the grade item "Grade Item"
    And I give the grade "30.00" to the user "Student_name Student_lastname" for the grade item "Grade Item 2"
    And I press "Save changes"

    Then I log in as "admin"
    And I navigate to "Grades > General settings" in site administration
    And I set the field "Grade export user profile fields" to "firstname,lastname,idnumber,institution,department,email,address"
    And I click on "Save changes" "button"
    And I log out

    And I log in as "teacher1"
    And I am on "Course 1" course homepage
    And I navigate to "Plain text file" export page in the course gradebook
    And I expand all fieldsets
    And  I set the following fields to these values:
      | First name   | 1                        |
      | Last name    | 1                        |
      | ID number    | 0                        |
      | Institution  | 0                        |
      | Department   | 0                        |
      | Email address| 0                        |
      | Address      | 1                        |
    And I press "Download"

    Then I should see "Group 1"
    And I should see "Student_name"
    And I should see "Student_lastname"
    And I should see "Address"
    And I should see "Wall Street"

    And I should see "Assigment 1"
    And I should see "50.0"
    And I should see "Grade Item"
    And I should see "80.0"
    And I should see "Grade Item 2"
    And I should see "30.0"
    And I should see "Grade Category total"
    And I should see "30.0"

