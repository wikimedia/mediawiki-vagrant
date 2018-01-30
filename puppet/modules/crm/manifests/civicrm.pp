# == Class: crm::civicrm
#
# CiviCRM with Wikimedia customizations
#
class crm::civicrm {
    $install_script = "${::crm::dir}/sites/default/civicrm-install.php"

    mysql::db { 'civicrm':
        dbname => $crm::civicrm_db,
    }

    mysql::user { $crm::db_user:
      ensure   => present,
      grant    => 'ALL ON *.*',
      password => $crm::db_pass,
      require  => Mysql::Db[$crm::civicrm_db],
    }

    exec { 'civicrm_setup':
        command => "/usr/bin/php ${install_script}",
        unless  => "/usr/bin/mysql -u ${::crm::db_user} -p${::crm::db_pass} ${::crm::civicrm_db} -B -N -e 'select 1 from civicrm_domain' | grep -q 1",
        require => [
            File[
                $install_script,
                'drupal_settings_php'
            ],
            Mysql::Db['civicrm'],
            Mysql::User[$crm::db_user],
        ],
    }

    $dir = $crm::dir

    file { $install_script:
        content => template('crm/civicrm-install.php.erb'),
        mode    => '0644',
        require => Git::Clone[$::crm::repo],
    }
}
