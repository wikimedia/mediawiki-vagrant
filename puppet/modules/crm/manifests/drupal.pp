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
# [*modules*]
#   Array of all modules that should be enabled
#
# [*settings*]
#   Map from drupal variable names to default values.
#
class crm::drupal(
    $dir,
    $files_dir,
    $modules,
    $settings = {},
) {
    include ::crm

    $install_script = "${dir}/sites/default/drupal-install.php"
    $settings_path = "${dir}/sites/default/settings.php"

    $databases = [
        $::crm::drupal_db,
        'donations',
        'fredge',
    ]

    $db_url = "mysql://${::crm::db_user}:${::crm::db_pass}@localhost/${::crm::drupal_db}"

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
        ensure    => link,
        target    => $files_dir,
        force     => true,
        require   => File["${dir}/sites/default"],
    }

    file { $install_script:
        content => template('crm/drupal-install.sh.erb'),
        mode    => '0755',
        require => Git::Clone[$::crm::repo],
    }

    mysql::db { $databases: }

    exec { 'drupal_db_install':
        command => $install_script,
        unless  => "mysql -u '${::crm::db_user}' -p'${::crm::db_pass}' '${::crm::drupal_db}' -e 'select 1 from system'",
        require => [
            Git::Clone[$::crm::repo],
            Mysql::Db[$databases],
            Package['drush'],
            File["${dir}/sites/default/files"],
        ],
    }

    file { 'drupal_settings_php':
        path    => $settings_path,
        content => template('crm/settings.php.erb'),
        mode    => '0644',
        require => Git::Clone[$::crm::repo],
    }

    exec { 'enable_drupal_modules':
        command     => inline_template('<%= scope["::crm::drush::wrapper"] %> pm-enable <%= @modules.join(" ") %>'),
        refreshonly => true,
        subscribe   => [
            Exec['drupal_db_install'],
        ],
        require     => [
            Exec['civicrm_setup'],
            File['drupal_settings_php'],
        ],
    }
}
