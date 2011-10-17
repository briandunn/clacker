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

  Scenario: multiple projects CSV
    Given this project file:
    """
    Fri Jun 24 09:00:00 CDT 2011: @internal standup
    Fri Jun 24 09:05:00 CDT 2011: @mulu-demo
    Fri Jun 24 11:25:00 CDT 2011: @off lunch
    Fri Jun 24 12:25:00 CDT 2011: @mulu
    Fri Jun 24 17:25:00 CDT 2011: @off outie
    """
    When I clack with the arguments:
      | day | 2011-06-24 |
    Then I see this CSV:
        | hours | project    | notes        |
        | 0.08  | @internal  | standup      |
        | 2.33  | @mulu-demo |              |
        | 7.58  | @off       | lunch\noutie |
        | 5.00  | @mulu      |              |
