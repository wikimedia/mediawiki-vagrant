# == Class: zotero
#
# Zotero is a service based on running the Zotero Firefox extension via xpcshell
# and JavaScript wrappers. It is meant to scrape URLs provided to it and return
# metadata.
#
# === Parameters
#
# [*base_path*]
#   Path to the zotero code. (e.g. /vagrant/srv/zotero)
#
# [*log_file*]
#   Place where zotero should log messages.
#
class zotero(
    $base_path,
    $log_file,
) {

    package { 'xulrunner-dev':
        ensure => present,
        before => Service['zotero'],
    }

    file { $base_path:
        ensure => directory,
        before => Service['zotero'],
        owner  => $::share_owner,
        group  => $::share_group,
    }

    git::clone{ 'mediawiki/services/zotero/translation-server':
        directory => "${base_path}/translation-server",
        require   => File[$base_path],
        before    => Service['zotero'],
    }

    git::clone{ 'mediawiki/services/zotero/translators':
        directory => "${base_path}/translators",
        require   => File[$base_path],
        before    => Service['zotero'],
    }

    file { "${base_path}/translation-server/defaults/preferences/defaults.js":
        ensure  => present,
        content => template('zotero/defaults.js.erb'),
        require => Git::Clone['mediawiki/services/zotero/translation-server'],
        notify  => Service['zotero'],
    }

    file { $log_file:
        ensure => present,
        mode   => '0666',
        owner  => $::share_owner,
        group  => $::share_group,
    }

    file { '/etc/init/zotero.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('zotero/upstart.conf.erb'),
        notify  => Service['zotero'],
    }

    service { 'zotero':
        enable     => true,
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        provider   => 'upstart',
        subscribe  => File['/etc/init/zotero.conf'],
    }
}
