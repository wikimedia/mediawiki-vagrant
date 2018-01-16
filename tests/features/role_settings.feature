Feature: Role settings

  Roles should be able to define changes to the core environment settings to
  better accommodate services requiring more memory, forwarded ports, etc.
  Such changes should be communicated to the user both when viewing
  documentation and upon enabling new roles. Enabling and disabling a role with
  settings should trigger a reload before the next provision and warn the user.

  Background:
    Given the following roles are defined:
      | foo |
      | bar |

  Scenario: Running `vagrant roles info <role>` displays the role's settings
    Given the settings for the "foo" role are:
      """
      vagrant_ram: 200
      """
    When I run `vagrant roles info foo`
    Then the command should have completed successfully
    And the output should contain:
      """
      Enabling this role will adjust the following settings:

      Amount of RAM (in MB) allocated to the guest VM
      vagrant_ram: 1536 -> 1736
      """

  Scenario: Running `vagrant roles enable <role>` warns of changes to settings
    Given my current settings are:
      """
      vagrant_ram: 1536
      forward_ports:
        123: 321
      """
    And the settings for the "foo" role are:
      """
      vagrant_ram: 200
      forward_ports:
        234: 432
      """
    When I run `vagrant roles enable foo`
    Then the command should have completed successfully
    And the output should contain:
      """
      Ok. Run `vagrant provision` to apply your changes.

      Note the following settings have changed and your environment will be reloaded.
      vagrant_ram: 1536 -> 1736
      forward_ports: { 123: 321 } -> { 123: 321, 234: 432 }
      """

  Scenario: Running `vagrant roles disable <role>` warns of changes to settings
    Given my current settings are:
      """
      vagrant_ram: 1536
      forward_ports:
        123: 321
      """
    And the settings for the "foo" role are:
      """
      vagrant_ram: 200
      forward_ports:
        234: 432
      """
    And the "foo" role is enabled
    When I run `vagrant roles disable foo`
    Then the command should have completed successfully
    And the output should contain:
      """
      Ok. Run `vagrant provision` to apply your changes.

      Note the following settings have changed and your environment will be reloaded.
      vagrant_ram: 1736 -> 1536
      forward_ports: { 123: 321, 234: 432 } -> { 123: 321 }
      """

  Scenario: Enabling a role that changes settings triggers a reload
    Given the settings for the "foo" role are:
      """
      vagrant_ram: 200
      """
    When I run `vagrant roles enable foo`
    Then the command should have completed successfully
    And a reload should have been triggered
