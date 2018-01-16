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
#   Branch to check out (example: 'master').
#
# [*git_depth*]
#  Git cloning depth - undef for normal, a number for a shallow clone with
#  that many revisions.
#
# [*server_url*]
#   Full base URL of host (example: 'http://mywiki.net:8080').
#
class mediawiki(
    $wiki_name,
    $admin_user,
    $admin_pass,
    $db_name,
    $dir,
    $cache_dir,
    $settings_dir,
    $upload_dir,
    $page_dir,
    $composer_fragment_dir,
    $branch     = undef,
    $git_depth  = undef,
    $server_url = undef,
) {
    Exec {
      environment => "MW_INSTALL_PATH=${dir}",
    }

    include ::mwv
    require ::php

    require ::service

    include ::mediawiki::apache
    include ::mediawiki::jobrunner
    include ::mediawiki::multiwiki
    include ::mediawiki::mwrepl
    include ::mediawiki::ready_service
    include ::mediawiki::psysh

    require_package('parallel', 'firejail')

    $managed_settings_dir = "${settings_dir}/puppet-managed"

    git::clone { 'mediawiki/core':
        # T152801 - avoid using gerrit for the initial cloning
        temp_remote => 'https://phabricator.wikimedia.org/source/mediawiki.git',
        directory   => $dir,
        branch      => $branch,
        depth       => $git_depth,
    }

    mediawiki::skin { 'Vector': }

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

    # Needed by ::mediawiki::import::text
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
            Git::Clone['mediawiki/core'],
            Php::Composer::Install[$dir],
        ],
    }

    mediawiki::user { "admin_user_in_steward_suppress_on_${db_name}":
        username => $admin_user,
        password => $admin_pass,
        wiki     => $db_name,
        groups   => [
            'steward',
            'suppress',
        ],
        require  => MediaWiki::Wiki[$wiki_name],
    }

    mediawiki::group { "${wiki_name}_suppress":
        wiki              => $wiki_name,
        group_name        => 'suppress',
        grant_permissions => [
            'deletelogentry',
            'deleterevision',
            'hideuser',
            'suppressrevision',
            'suppressionlog',
            'viewsuppressed',
        ],
    }

    env::var { 'MW_INSTALL_PATH':
        value => $dir,
    }

    file { "${mediawiki::apache::docroot}/mediawiki-vagrant.png":
        source => 'puppet:///modules/mediawiki/mediawiki-vagrant.png',
    }

    file { "${mediawiki::apache::docroot}/mediawiki-vagrant-1.5x.png":
        source => 'puppet:///modules/mediawiki/mediawiki-vagrant-1.5x.png',
    }

    file { "${mediawiki::apache::docroot}/mediawiki-vagrant-2x.png":
        source => 'puppet:///modules/mediawiki/mediawiki-vagrant-2x.png',
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

    file { '/usr/local/bin/export-mediawiki-dump':
        source => 'puppet:///modules/mediawiki/export-mediawiki-dump',
        mode   => '0755',
    }

    exec { 'update_all_databases':
        command     => '/usr/local/bin/foreachwiki update.php --quick --doshared',
        cwd         => $dir,
        user        => 'www-data',
        refreshonly => true,
        require     => Exec["composer update ${dir}"],
    }

    # Make sure settings which will affect update_all_databases are
    # in place before db updates run.
    Mediawiki::Settings <| |> -> Exec['update_all_databases']

    # Make sure all wikis are defined before db updates run.
    Mediawiki::Wiki <| |> -> Exec['update_all_databases']

    # Ensure that vendor directory exists before db updates run.
    Php::Composer::Install <| |> -> Exec['update_all_databases']

    php::composer::install { $dir:
        require => Git::Clone['mediawiki/core'],
    }

    # Needed by mediawiki::composer::require
    file { $composer_fragment_dir:
        ensure  => directory,
        recurse => true,
        purge   => true,
        notify  => Exec["composer update ${dir}"],
    }

    file { "${dir}/composer.local.json":
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => '0664',
        source  => 'puppet:///modules/mediawiki/composer.local.json',
        require => Git::Clone['mediawiki/core'],
    }

    exec { "composer update ${dir}":
        command     => '/usr/local/bin/composer update --no-progress',
        cwd         => $::mediawiki::dir,
        environment => [
            "COMPOSER_HOME=${::php::composer::home}",
            "COMPOSER_CACHE_DIR=${::php::composer::cache_dir}",
            'COMPOSER_NO_INTERACTION=1',
        ],
        refreshonly => true,
        require     => [
            Php::Composer::Install[$::mediawiki::dir],
            File["${dir}/composer.local.json"],
        ],
    }

    env::profile_script { 'add mediawiki vendor bin to path':
        content => "export PATH=\$PATH:${dir}/vendor/bin",
    }

    mediawiki::import::text { 'Main_Page':
        source => 'puppet:///modules/mediawiki/main_page.wiki',
    }

    mediawiki::import::text { 'Template:Main_Page':
        source => 'puppet:///modules/mediawiki/main_page_template.wiki',
    }

    file { '/etc/logrotate.d/mediawiki_shared_log_groups':
        source => 'puppet:///modules/mediawiki/wiki/logrotate.d-mediawiki-shared-log-groups',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }
}
