# == Class: crm::civicrm
#
# CiviCRM with Wikimedia customizations
#
class crm::civicrm (
    $db_name,
    $db_user,
    $db_pass,
    $drupal_dir,
    $drupal_db_name,
    $drupal_db_user,
    $drupal_db_pass,
    $buildkit_repo,
    $buildkit_dir,
    $dir,
    $install_script,
) {
    mysql::db { 'civicrm':
        dbname => $db_name,
    }

    mysql::user { $db_user:
        ensure   => present,
        grant    => 'ALL ON *.*',
        password => $db_pass,
        require  => Mysql::Db[$db_name],
    }

    git::clone { 'civicrm buildkit':
        directory => $buildkit_dir,
        remote    => $buildkit_repo,
    }

    exec { 'civicrm_setup':
        command => "/usr/bin/php ${install_script}",
        unless  => "/usr/bin/mysql -u ${db_user} -p${db_pass} ${db_name} -B -N -e 'select 1 from civicrm_domain' | grep -q 1",
        require => [
            File[
                $install_script,
                'drupal_settings_php'
            ],
            Mysql::Db[$db_name],
            Mysql::User[$db_user],
        ],
    }

    # This makes life easier by not requiring folks to manually run db trigger updates
    # after each CiviCRM upgrade.
    exec { 'give_civicrm_upgrade_process_mysql_trigger_permissions':
      command => "/usr/bin/mysql -u'${db_user}' -p'${db_pass}' '${db_name}' -e \"UPDATE civicrm_setting
      SET value='i:0;' WHERE name='logging_no_trigger_permission'\"",
      unless  => "/usr/bin/mysql -u ${db_user} -p${db_pass} ${db_name} -e \"SELECT value
      FROM civicrm_setting WHERE name='logging_no_trigger_permission';\" | grep 'i:0;'",
      require => Exec['civicrm_setup'],
    }

    exec { 'civicrm_buildkit_setup':
        command     => "${buildkit_dir}/bin/civi-download-tools",
        environment => [
          'COMPOSER_HOME=/tmp',
          'COMPOSER_CACHE_DIR=/tmp',
          'COMPOSER_NO_INTERACTION=1',
          'COMPOSER_PROCESS_TIMEOUT=600',
        ],
        user        => 'vagrant',
        unless      => "/usr/bin/test -f ${buildkit_dir}/bin/cv",
        require     => [
          Git::Clone['civicrm buildkit'],
          Class['php::composer'],
        ]
    }

    env::profile_script { 'add civicrm buildkit bin to path':
        content => "export PATH=\$PATH:${buildkit_dir}/bin",
        require => Exec['civicrm_buildkit_setup'],
    }

    file { $install_script:
        content => template('crm/civicrm-install.php.erb'),
        mode    => '0644',
        require => Git::Clone[$::crm::repo],
    }

    file { '/etc/cron.d/crm':
        content => template('crm/crm.cron.d.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644'
    }

}
