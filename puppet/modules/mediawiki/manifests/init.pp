# == Class: mediawiki
#
# MediaWiki is a free software open source wiki package written in PHP,
# originally for use on Wikipedia.
#
# === Parameters
#
# [*wiki_name*]
#   The name of your site (example: 'devwiki').
#
# [*admin_user*]
#   User name for the initial admin account (example: 'admin').
#
# [*admin_pass*]
#   Initial password for admin account (example: 'secret123').
#
# [*db_name*]
#   Logical MySQL database name (example: 'devwiki').
#
# [*db_user*]
#   MySQL user to use to connect to the database (example: 'wikidb').
#
# [*db_pass*]
#   Password for MySQL account (example: 'secret123').
#
# [*branch*]
#   Version to check out
#
# [*dir*]
#   The system path to which MediaWiki files have been installed
#   (example: '/srv/mediawiki').
#
# [*cache_dir*]
#   Directory to use for caching interface messages (l10n cache).
#   (example: '/var/cache/mediawiki').
#
# [*settings_dir*]
#   Directory to use for configuration fragments.
#   (example: '/srv/mediawiki/settings.d').
#
# [*upload_dir*]
#   The file system path of the folder where files will be uploaded
#   (example: '/srv/mediawiki/images').
#
# [*server_url*]
#   Full base URL of host (example: 'http://mywiki.net:8080').
#
class mediawiki(
    $wiki_name,
    $admin_user,
    $admin_pass,
    $db_name,
    $db_pass,
    $db_user,
    $dir,
    $cache_dir,
    $settings_dir,
    $upload_dir,
    $branch     = undef,
    $server_url = undef,
) {
    Exec {
      environment => "MW_INSTALL_PATH=${dir}",
    }

    include ::php
    include ::hhvm

    include mediawiki::apache
    include mediawiki::jobrunner

    $managed_settings_dir = "${settings_dir}/puppet-managed"

    $installer_args = {
        dbname     => $db_name,
        dbpass     => $db_pass,
        dbuser     => $db_user,
        pass       => $admin_pass,
        scriptpath => '/w',
        server     => $server_url,
    }

    git::clone { 'mediawiki/core':
        directory => $dir,
        branch    => $branch,
    }

    # If an auto-generated LocalSettings.php file exists but the database it
    # refers to is missing, assume it is residual of a discarded instance and
    # delete it.
    exec { 'check_settings':
        command => 'rm -f LocalSettings.php',
        cwd     => $dir,
        unless  => 'start mediawiki-bridge && php5 maintenance/sql.php </dev/null',
        require => [ Service['mysql'], File['mediawiki_upstart_bridge'] ],
        notify  => Exec['mediawiki_setup'],
    }

    file { 'mediawiki_upstart_bridge':
        path    => '/etc/init/mediawiki-bridge.conf',
        content => template('mediawiki/mediawiki-bridge.conf.erb'),
        require => Git::Clone['mediawiki/core'],
    }

    file { $settings_dir:
        ensure => directory,
        owner  => $::share_owner,
        group  => $::share_group,
    }

    file { [ $cache_dir, $upload_dir ]:
        ensure => directory,
        owner  => 'vagrant',
        group  => 'www-data',
        mode   => '0775',
    }

    file { $managed_settings_dir:
        ensure  => directory,
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => undef,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/mediawiki/mediawiki-settings.d-empty',
    }

    exec { 'mediawiki_setup':
        command => template('mediawiki/install.php.erb'),
        creates => "${dir}/LocalSettings.php",
        require => [ Exec['set_mysql_password'], Git::Clone['mediawiki/core'], File[$upload_dir] ],
    }

    exec { 'include_extra_settings':
        command => 'echo "include_once \'/vagrant/LocalSettings.php\';" >> LocalSettings.php',
        cwd     => $dir,
        unless  => 'grep "/vagrant/LocalSettings.php" LocalSettings.php',
        require => Exec['mediawiki_setup'],
    }

    env::var { 'MW_INSTALL_PATH':
        value => $dir,
    }

    file { '/var/www/mediawiki-vagrant.png':
        source => 'puppet:///modules/mediawiki/mediawiki-vagrant.png',
    }

    file { '/usr/local/bin/run-mediawiki-tests':
        source  => 'puppet:///modules/mediawiki/run-mediawiki-tests',
        mode    => '0755',
    }

    file { '/usr/local/bin/run-git-update':
        source  => 'puppet:///modules/mediawiki/run-git-update',
        mode    => '0755',
    }

    file { '/usr/local/bin/import-mediawiki-dump':
        source  => 'puppet:///modules/mediawiki/import-mediawiki-dump',
        mode    => '0755',
    }

    exec { 'update_database':
        command     => 'php5 maintenance/update.php --quick',
        cwd         => $dir,
        user        => 'www-data',
        refreshonly => true,
    }

    exec { 'install_composer_deps':
        command     => 'composer install --no-interaction --optimize-autoloader',
        cwd         => $dir,
        environment => [
          'COMPOSER_HOME=/vagrant/cache/composer',
          'COMPOSER_CACHE_DIR=/vagrant/cache/composer',
        ],
        user        => 'vagrant',
        creates     => "${dir}/vendor",
        require     => Git::Clone['mediawiki/core'],
    }
}
