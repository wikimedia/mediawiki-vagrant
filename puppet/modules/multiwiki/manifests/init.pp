# == Class: multiwiki
#
# Basic support for running multiple wikis.
#
# Creates an Apache named virtual host listening for connections to
# '*.wiki.local.wmftest.net'. Use multiwiki::wiki to define a new wiki and
# multiwiki::extension and multiwiki::settings to configure it.
#
class multiwiki {
    require role::mediawiki

    $settings_root = "${::role::mediawiki::settings_dir}/multiwiki"
    $docroot       = '/srv/multiwiki'
    $upload_dir    = $::role::mediawiki::upload_dir

    File {
        owner => 'vagrant',
        group => 'www-data',
    }

    file { $settings_root:
        ensure  => directory,
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => '0755',
        recurse => true,
        purge   => true,
        force   => true,
    }

    file { "${settings_root}/CommonSettings.php":
        ensure  => present,
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => '0644',
        source  => 'puppet:///modules/multiwiki/CommonSettings.php',
    }

    file { "${settings_root}/LoadWgConf.php":
        ensure  => present,
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => '0644',
        content => template('multiwiki/LoadWgConf.php.erb'),
    }

    file { $docroot:
        ensure  => directory,
        mode    => '0755',
        source  => 'puppet:///modules/multiwiki/docroot',
        recurse => true,
    }

    file { "${docroot}/dblist.php":
        ensure  => present,
        mode    => '0644',
        content => template('multiwiki/docroot/dblist.php.erb'),
    }

    file { "${docroot}/defines.php":
        ensure  => present,
        mode    => '0644',
        content => template('multiwiki/docroot/defines.php.erb'),
    }

    file { "${docroot}/extensions":
        ensure => link,
        target => "${::role::mediawiki::dir}/extensions",
    }

    file { "${docroot}/resources":
        ensure => link,
        target => $::role::mediawiki::dir,
    }

    file { "${docroot}/skins":
        ensure => link,
        target => "${::role::mediawiki::dir}/skins",
    }

    file { "${docroot}/COPYING":
        ensure => link,
        target => "${::role::mediawiki::dir}/COPYING",
    }

    file { "${docroot}/CREDITS":
        ensure => link,
        target => "${::role::mediawiki::dir}/CREDITS",
    }

    file { '/usr/local/bin/multiversion-install':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('multiwiki/multiversion-install.erb'),
    }

    file { '/usr/local/bin/mwscript':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        source  => 'puppet:///modules/multiwiki/mwscript',
    }

    apache::site { 'multiwiki':
        ensure  => present,
        content => template('multiwiki/apache.conf.erb'),
    }

    mediawiki::settings { 'load multiwiki config':
        priority => $::LOAD_FIRST,
        values   => "include_once( '${settings_root}/LoadWgConf.php' );",
    }
}
