# == Class: crm::civicrm
#
# CiviCRM with Wikimedia customizations
#
class crm::civicrm {
    $install_script = "${::crm::dir}/sites/default/civicrm-install.php"

    mysql::db { 'civicrm':
        dbname => $crm::civicrm_db,
    }

    exec { 'civicrm_setup':
        command => "php5 ${install_script}",
        unless  => "mysql -u ${::crm::db_user} -p${::crm::db_pass} ${::crm::civicrm_db} -e 'select count(*) from civicrm_domain'",
        require => [
            File[$install_script],
            Mysql::Db['civicrm'],
            Exec['drupal_db_install'],
        ],
    }

    file { $install_script:
        content => template('crm/civicrm-install.php.erb'),
        mode    => '0640',
        owner   => 'www-data',
        group   => 'www-data',
        require => Git::Clone[$::crm::repo],
    }
}
