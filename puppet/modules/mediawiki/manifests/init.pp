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
# [*dir*]
#   The system path to which MediaWiki files have been installed
#   (example: '/srv/mediawiki').
#
# [*cache_dir*]
#   Root directory to use for caching interface messages (l10n cache). Note
#   that each instance of mediawiki::wiki will create its own subdirectory.
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
# [*page_dir*]
#   The file system path of the folder where the content of vagrant-managed
#   pages is stored (example: '/srv/pages').
#
# [*branch*]
#   Version to check out
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
    $page_dir,
    $branch     = undef,
    $server_url = undef,
) {
    Exec {
      environment => "MW_INSTALL_PATH=${dir}",
    }

    include ::mwv
    require ::php
    require ::hhvm

    include ::mediawiki::apache
    include ::mediawiki::jobrunner
    include ::mediawiki::multiwiki

    $managed_settings_dir = "${settings_dir}/puppet-managed"

    git::clone { 'mediawiki/core':
        directory => $dir,
        branch    => $branch,
    }

    mediawiki::skin { 'Vector': }

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

    file { $cache_dir:
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

    # needed by import_page
    file { [$page_dir, "${page_dir}/wiki"]:
        ensure => directory,
    }

    mediawiki::wiki { $wiki_name:
        db_name      => $db_name,
        upload_dir   => $upload_dir,
        upload_path  => '/images',
        server_url   => $server_url,
        primary_wiki => true,
        require      => [
            Exec['set_mysql_password'],
            Git::Clone['mediawiki/core'],
        ],
    }

    env::var { 'MW_INSTALL_PATH':
        value => $dir,
    }

    file { "${mediawiki::apache::docroot}/mediawiki-vagrant.png":
        source => 'puppet:///modules/mediawiki/mediawiki-vagrant.png',
    }

    file { '/usr/local/bin/run-mediawiki-tests':
        source => 'puppet:///modules/mediawiki/run-mediawiki-tests',
        mode   => '0755',
    }

    file { '/usr/local/bin/run-git-update':
        content => template('mediawiki/run-git-update.erb'),
        mode    => '0755',
    }

    file { '/usr/local/bin/import-mediawiki-dump':
        source => 'puppet:///modules/mediawiki/import-mediawiki-dump',
        mode   => '0755',
    }

    exec { 'update_all_databases':
        command     => 'foreachwiki update.php --quick',
        cwd         => $dir,
        user        => 'www-data',
        refreshonly => true,
    }

    php::composer::install { $dir:
        require => Git::Clone['mediawiki/core'],
    }

    env::profile_script { 'add mediawiki vendor bin to path':
        content => "export PATH=\$PATH:${dir}/vendor/bin",
    }

    mediawiki::import_text { 'Main_Page':
        source => 'puppet:///modules/mediawiki/main_page.wiki',
    }

    mediawiki::import_text { 'Template:Main_Page':
        source => 'puppet:///modules/mediawiki/main_page_template.wiki',
    }

    file { '/etc/logrotate.d/mediawiki_shared_log_groups':
        source => 'puppet:///modules/mediawiki/wiki/logrotate.d-mediawiki-shared-log-groups',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }
}
