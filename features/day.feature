Feature: day summary

  As a time tracker
  In order to see how I spent my time on a day
  I can print out a CSV

  Scenario: one entry CSV
    Given this project file:
    """
    Tue Oct 11 07:45:00 CDT 2011: @clacker
    Tue Oct 11 08:00:00 CDT 2011: @off
    """
    When I clack with the arguments:
      | day | 2011-10-11 |
    Then I see this CSV:
      | hours | project  |
      | 0.25  | @clacker |
      | 16.00 | @off     |

