Feature: Command line role management

  Management of roles should be available from the command line so that
  developers can easily enable/disable functionality of their current
  environment and more efficiently multitask.

  Background:
    Given the following roles are defined:
      | foo |
      | bar |
      | baz |

  Scenario: Running `vagrant list-commands` includes `roles`
    When I run `vagrant list-commands`
    Then the command should have completed successfully
    And the tabular output should contain:
      | roles | manage mediawiki-vagrant roles: list, enable, disable, etc. |

  Scenario: Running `vagrant roles --help` prints usage
    When I run `vagrant roles --help`
    Then the command should have completed successfully
    And the output should contain:
      """
      Usage: vagrant roles <command> [<args>]
      """

  Scenario: Running `vagrant roles list` lists columns of available roles
    Given the "foo" role is enabled
    When I run `vagrant roles list` interactively
    Then the command should have completed successfully
    And the output should contain:
      """
      Available roles:

        bar                        baz                      * foo
      """

  Scenario: Running `vagrant roles list -1` lists roles, one per line
    Given the "foo" role is enabled
    When I run `vagrant roles list -1` interactively
    Then the command should have completed successfully
    And the output should be:
      """
        bar
        baz
      * foo
      """

  Scenario: Running `vagrant roles list -e` lists enabled roles only
    Given the "foo" role is enabled
    When I run `vagrant roles list -e` interactively
    Then the command should have completed successfully
    And the output should contain:
      """
      Enabled roles:

      foo
      """

  Scenario: Running `vagrant roles list -e1` lists enabled roles only, one per line
    Given the "foo" role is enabled
    When I run `vagrant roles list -e1` interactively
    Then the command should have completed successfully
    And the output should be:
      """
      foo
      """

  Scenario: Running `vagrant roles info <role>` displays the role's documentation
    Given the "foo" role is defined as:
      """
      # == Class: role::foo
      #
      # Sets up some foo.
      #
      class role::foo {}
      """
    When I run `vagrant roles info foo`
    Then the command should have completed successfully
    And the output should be:
      """
      Class: role::foo

      Sets up some foo.


      """

  Scenario: Running `vagrant roles enable <role>` enables a role
    When I run `vagrant roles enable foo`
    Then the command should have completed successfully
    And the "foo" role should be enabled

  Scenario: Running `vagrant roles enable <role>` complains about invalid roles
    When I run `vagrant roles enable badrole`
    Then the command should have completed unsuccessfully
    And the errors should contain:
      """
      'badrole' is not a valid role.
      """

  Scenario: Running `vagrant roles disable <role>` disables a role
    Given the "foo" role is enabled
    When I run `vagrant roles disable foo`
    Then the command should have completed successfully
    And the "foo" role should be disabled

  Scenario: Running `vagrant roles disable <role>` complains about already disabled roles
    Given the "foo" role is enabled
    When I run `vagrant roles disable bar`
    Then the command should have completed unsuccessfully
    And the errors should contain:
      """
      'bar' is not currently enabled.
      """

  Scenario: Running `vagrant roles reset` disables all roles
    Given the "foo" role is enabled
    And the "bar" role is enabled
    When I run `vagrant roles reset`
    Then the command should have completed successfully
    And the "foo" role should be disabled
    And the "bar" role should be disabled
