Feature: Command line configuration

  Simple VM configurations should be manageable from the command line so that
  developers can easily fine tune settings that are appropriate to their
  systems and workflows.

  Scenario: Running `vagrant list-commands` includes `config`
    When I run `vagrant list-commands`
    Then the command should have completed successfully
    And the tabular output should contain:
      | config | configures mediawiki-vagrant settings |

  Scenario: Running `vagrant config --help` prints usage
    When I run `vagrant config --help`
    Then the command should have completed successfully
    And the output should contain:
      """
      Usage: vagrant config [options] [name] [value]
      """

  Scenario: Running `vagrant config --list` lists available settings
    When I run `vagrant config --list`
    Then the command should have completed successfully
    And the first column of output should contain:
      | git_user      |
      | vagrant_ram   |
      | vagrant_cores |
      | static_ip     |
      | http_port     |
      | https_port    |
      | nfs_shares    |
      | nfs_force_v3  |
      | forward_agent |
      | forward_x11   |

  Scenario: Running `vagrant config --list` displays each setting's current value
    Given the "http_port" setting is "8081"
    When I run `vagrant config --list`
    Then the command should have completed successfully
    And the output should contain:
      """
      Current value: 8081
      """

  Scenario: Running `vagrant config --list` indicates current default values
    When I run `vagrant config --list`
    Then the command should have completed successfully
    And the output should contain:
      """
      Current value: 8080 (default)
      """

  Scenario: Running `vagrant config name value` configures a setting
    When I run `vagrant config foo bar`
    Then the command should have completed successfully
    And the "foo" setting should be "bar"

  Scenario: Running `vagrant config --get name` outputs a setting
    Given the "foo" setting is "bar"
    When I run `vagrant config --get foo`
    Then the command should have completed successfully
    And the output should contain "bar"

  Scenario: Running `vagrant config --unset name` removes a setting
    Given the "foo" setting is "bar"
    When I run `vagrant config --unset foo`
    Then the command should have completed successfully
    And the "foo" setting should not be configured

  Scenario: Running `vagrant config --all` prompts for each available setting
    When I run `vagrant config --all` interactively
    And I enter the following at each prompt:
      | git_user      | foo     |
      | vagrant_ram   | 8096    |
      | vagrant_cores | 8       |
      | static_ip     | 1.1.1.1 |
      | http_port     | 8888    |
      | https_port    | 4433    |
      | host_ip       | 0.0.0.0 |
      | nfs_shares    | no      |
      | nfs_force_v3  | no      |
      | nfs_cache     | yes     |
      | forward_agent | yes     |
      | forward_x11   | no      |
    Then the command should have completed successfully
    And the current settings should be:
      | git_user      | foo     |
      | vagrant_ram   | 8096    |
      | vagrant_cores | 8       |
      | static_ip     | 1.1.1.1 |
      | http_port     | 8888    |
      | https_port    | 4433    |
      | host_ip       | 0.0.0.0 |
      | nfs_shares    | no      |
      | nfs_force_v3  | no      |
      | nfs_cache     | yes     |
      | forward_agent | yes     |
      | forward_x11   | no      |

  Scenario: Running `vagrant config --required` prompts for only required settings
    Given the "git_user" setting is not configured
    When I run `vagrant config --required` interactively
    And I enter the following at each prompt:
      | git_user | foo |
    Then the command should have completed successfully
    And the current settings should be:
      | git_user | foo |

  Scenario: Running `vagrant config --required` skips configured settings
    Given the "git_user" setting is "foo"
    When I run `vagrant config --required` interactively
    Then the command should have completed successfully
