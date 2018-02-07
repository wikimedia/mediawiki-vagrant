# == Class: crm::drupal
#
# Drupal and modules
#
# === Parameters
#
# [*dir*]
#   Drupal installation directory.
#
# [*files_dir*]
#   Directory used for Drupal file store.
#
# [*drupal_settings*]
#   Map from drupal variable names to default values.
#
class crm::drupal(
    $dir,
    $files_dir,
    $drupal_settings = {},
) {
    include ::crm

    $install_script = "${dir}/sites/default/drupal-install.sh"
    $settings_path = "${dir}/sites/default/settings.php"
    $module_list = "${dir}/sites/default/enabled_modules"

    $databases = [
        $::crm::drupal_db,
        'donations',
        'fredge',
    ]

    $db_url = "mysql://${::crm::db_user}:${::crm::db_pass}@localhost/${::crm::drupal_db}"

    $audit_base = '/var/spool/audit'

    class { 'crm::drush':
        root => $dir,
    }

    file { $files_dir:
        ensure    => directory,
        group     => 'www-data',
        mode      => '2775',
        recurse   => true,
        subscribe => Exec['civicrm_setup'],
    }

    file { "${dir}/sites/default":
        mode => '0755',
    }

    file { "${dir}/sites/default/files":
        ensure  => link,
        target  => $files_dir,
        force   => true,
        require => File["${dir}/sites/default"],
    }

    file { $install_script:
        content => template('crm/drupal-install.sh.erb'),
        mode    => '0755',
        require => Git::Clone[$::crm::repo],
    }

    file { [ $audit_base,
            "${audit_base}/amazon",
            "${audit_base}/astropay",
            "${audit_base}/amazon/incoming",
            "${audit_base}/amazon/completed",
            "${audit_base}/astropay/incoming",
            "${audit_base}/astropay/completed",
        ]:
        ensure  => directory,
        group   => 'www-data',
        mode    => '2775',
        recurse => true,
    }

    mysql::db { $databases: }

    exec { 'drupal_db_install':
        command => $install_script,
        unless  => "/usr/bin/mysql -u'${::crm::db_user}' -p'${::crm::db_pass}' '${::crm::drupal_db}' -e 'select 1 from system'",
        require => [
            Git::Clone[$::crm::repo],
            Mysql::User[$crm::db_user],
            Mysql::Db[$databases],
            Class['crm::drush'],
            File["${dir}/sites/default/files"],
        ],
    }

    file { 'drupal_settings_php':
        path    => $settings_path,
        content => template('crm/settings.php.erb'),
        mode    => '0644',
        require => Git::Clone[$::crm::repo],
    }

    file { 'drupal_donationinterface_settings_php':
        path    => "${dir}/sites/default/DonationInterface.settings.php",
        content => template('crm/DonationInterface.settings.php.erb'),
        mode    => '0644',
        require => Git::Clone[$::crm::repo],
    }

    exec { 'enable_drupal_modules':
      command   => inline_template(
          '<%= scope["::crm::drush::wrapper"] %> pm-enable `cat <%= @module_list %>` '),
      subscribe => Exec['drupal_db_install'],
      require   => [
          Exec['civicrm_setup'],
          File['drupal_settings_php'],
      ],
    }

    # TODO: When you realise what this is doing, you won't like it (email fr-tech@wikimedia.org with abuse if it lingers)
    # paymentswiki/donationInterface can't run unit tests without the table `unittest_contribution_tracking`
    # due to paymentswiki/drupal coupling so we add it here to avoid headache for people trying to work it out.
    exec { 'add_missing_unittest_contribution_tracking_table':
      command => "/usr/bin/mysql -u'${::crm::db_user}' -p'${::crm::db_pass}' -e \"show create table contribution_tracking\" -D drupal \
                  | sed -ne 's/contribution_tracking/unittest_contribution_tracking/g' -Ee 's/^.*(CREATE.*)$/\\1/p' \
                  | /usr/bin/mysql -u'${::crm::db_user}' -p'${::crm::db_pass}' -D drupal",
      unless  => "/usr/bin/mysql -u'${::crm::db_user}' -p'${::crm::db_pass}' '${::crm::drupal_db}' -e 'select 1 from unittest_contribution_tracking'",
      require => Exec['enable_drupal_modules'],
    }

    exec { 'update_exchange_rates':
        command => inline_template('<%= scope["::crm::drush::wrapper"] %> exchange-rates-update'),
        unless  => "/usr/bin/mysql -u '${::crm::db_user}' -p'${::crm::db_pass}' '${::crm::drupal_db}' -B -N -e 'select 1 from exchange_rates') | grep -q 1",
        require => Exec['enable_drupal_modules'],
    }
}
