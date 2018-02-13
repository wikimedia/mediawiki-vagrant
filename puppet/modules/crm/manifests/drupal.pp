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
    $fredge_db_name,
    $db_name,
    $db_user,
    $db_pass,
    $civicrm_db_name,
    $civicrm_db_user,
    $civicrm_db_pass,
    $civicrm_templates_dir,
    $smashpig_db_name,
    $smashpig_db_user,
    $smashpig_db_pass,
    $dir,
    $files_dir,
    $install_script,
    $settings_path,
    $module_list,
    $drupal_settings = {},
) {
    include ::crm

    $databases = [
        $db_name,
        $fredge_db_name,
    ]

    $db_url = "mysql://${db_user}:${db_pass}@localhost/${db_name}"

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

  mysql::user { $db_user:
    ensure   => present,
    grant    => 'ALL ON *.*',
    password => $db_pass,
    require  => Mysql::Db[$databases],
  }

    mysql::db { $databases: }

    exec { 'drupal_db_install':
        command => $install_script,
        unless  => "/usr/bin/mysql -u'${db_user}' -p'${db_pass}' '${db_name}' -e 'select 1 from system'",
        require => [
            Git::Clone[$::crm::repo],
            Mysql::User[$db_user],
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

    exec { 'reset_drupal_cache':
        command => 'drush cc all',
        require => [
            Exec['drupal_db_install'],
        ],
    }

    # drupal sets project-wide recursive perms which we have to update to allow unit tests to run as vagrant
    file { 'set civicrm template file permissions':
        path      => $civicrm_templates_dir,
        group     => 'vagrant',
        recurse   => true,
        require   => Exec['drupal_db_install'],
        subscribe => File[$files_dir],
    }

    # paymentswiki/donationInterface can't run unit tests without the table `unittest_contribution_tracking`
    # due to paymentswiki/drupal coupling so we add it here to avoid headache for people trying to work it out.
    exec { 'add_missing_unittest_contribution_tracking_table':
        command => "/usr/bin/mysql -u'${db_user}' -p'${db_pass}' '${db_name}' -e \"show create table contribution_tracking\" \
                    | sed -ne 's/contribution_tracking/unittest_contribution_tracking/g' -Ee 's/^.*(CREATE.*)$/\\1/p' \
                    | /usr/bin/mysql -u'${db_user}' -p'${db_pass}' '${db_name}'",
        unless  => "/usr/bin/mysql -u'${db_user}' -p'${db_pass}' '${db_name}' -e 'select 1 from unittest_contribution_tracking'",
        require => Exec['enable_drupal_modules'],
    }

    exec { 'update_exchange_rates':
        command => inline_template('<%= scope["::crm::drush::wrapper"] %> exchange-rates-update'),
        unless  => "/usr/bin/mysql -u'${db_user}' -p'${db_pass}' '${db_name}' -B -N -e 'select 1 from exchange_rates') | grep -q 1",
        require => Exec['enable_drupal_modules'],
    }
}