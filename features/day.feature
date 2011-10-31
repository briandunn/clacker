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

  Scenario: group by project
    Given this project file:
    """
    Fri Jun 24 09:00:00 CDT 2011: @clacker
    Fri Jun 24 09:15:00 CDT 2011: @off
    Fri Jun 24 11:00:00 CDT 2011: @clacker
    Fri Jun 24 12:00:00 CDT 2011: @off
    """
    When I clack with the arguments:
      | day | 2011-06-24 |
    Then I see this CSV:
      | hours | project  | notes |
      | 1.25  | @clacker |       |
      | 13.75 | @off     |       |

  Scenario: with commit messages
    Given a git repo at ./hashboard
    And that repo has the following commit:
      | message | Made it awesome |
    And this project file:
    """
    @hashboard:
      path: hashboard
    '07:45:00 UTC': @hashboard
    '08:00:00 UTC': @off
    """
    When I run `day` with today's date
    Then I see this CSV:
        | hours | project    | notes           |
        | 0.25  | @hashboard | Made it awesome |
        | 21.00 | @off       |                 |

  Scenario: posting to harvest
    Given this project file:
    """
    @clacker:
      harvest: { project_id: 259737, task_id: 232419 }
    Tue Oct 11 07:45:00 CDT 2011: @clacker made it awesome
    Tue Oct 11 08:00:00 CDT 2011: @off
    """
    When I clack with the arguments:
      | day | 2011-10-11 | --harvest |
    Then harvest has the following entry:
      | spent at | 2011-10-11       |
      | project  | Internal         |
      | task     | Open Source Work |
      | hours    | 0.25             |
      | notes    | made it awesome  |
