# == Class: role::phragile
# Class to setup phragile install
class role::phragile(
    $install_dir,
    $debug,
    $vhost_name,
) {
    include ::apache
    include ::apache::mod::rewrite
    include ::mysql
    include ::php
    include ::phabricator

    phabricator::config { 'phabricator.show-prototypes':
        deploy_dir => $::phabricator::deploy_dir,
        value      => true,
    }

    git::clone { 'https://github.com/wmde/phragile.git':
        directory => $install_dir,
        remote    => 'https://github.com/wmde/phragile.git',
    }

    service::gitupdate { 'phragile':
        dir    => $install_dir,
        type   => 'php',
        update => true,
    }

    file { "${install_dir}/.env":
        content => template('role/phragile/env.erb'),
        require => Git::Clone['https://github.com/wmde/phragile.git'],
        replace => false,
    }

    exec { 'update_phragile_app_key':
        command => template('role/phragile/update_app_key.erb'),
        cwd     => $install_dir,
        unless  => "grep -q ^APP_KEY ${install_dir}/.env",
        require => File["${install_dir}/.env"],
    }

    php::composer::install { $install_dir:
        require => Git::Clone['https://github.com/wmde/phragile.git'],
    }

    apache::site { $vhost_name:
        ensure  => present,
        content => template('role/phragile/apache.conf.erb'),
        require => Class['::apache::mod::rewrite'],
    }

    mysql::db { 'phragile': }

    exec { 'php artisan migrate':
        cwd     => $install_dir,
        require => Mysql::Db['phragile'],
    }
}
