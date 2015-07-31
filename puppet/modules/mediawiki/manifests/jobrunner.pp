# == Class: mediawiki::jobrunner
#
# jobrunner continuously processes the MediaWiki job queue by dispatching
# workers to perform tasks and monitoring their success or failure.
#
# === Parameters
#
# [*enable*]
#   Enable/disable jobrunner services.
#
# [*dir*]
#   Installation directory.
#
class mediawiki::jobrunner(
    $enable,
    $dir,
) {
    require ::mediawiki

    $ensure = $enable ? {
        false   => 'stopped',
        default => 'running',
    }

    $restart = $enable ? {
        false   => false,
        default => true,
    }

    git::clone { 'mediawiki/services/jobrunner':
        directory => $dir,
        before    => Service['jobrunner'],
    }

    file { '/etc/default/jobrunner':
        source => 'puppet:///modules/mediawiki/jobrunner.default',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        notify => Service['jobrunner'],
    }

    file { '/etc/init/jobrunner.conf':
        content => template('mediawiki/jobrunner.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        notify  => Service['jobrunner'],
    }

    file { '/etc/init/jobchron.conf':
        content => template('mediawiki/jobchron.conf.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        notify  => Service['jobchron'],
    }

    file { '/etc/jobrunner.ini':
        ensure => absent,
    }

    file { '/etc/jobrunner.json':
        content => template('mediawiki/jobrunner.json.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        notify  => [
            Service['jobrunner'],
            Service['jobchron'],
        ]
    }

    file { '/etc/logrotate.d/mediawiki_jobrunner':
        source => 'puppet:///modules/mediawiki/logrotate.d_mediawiki_jobrunner',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }

    file { '/etc/logrotate.d/mediawiki_jobchron':
        source => 'puppet:///modules/mediawiki/logrotate.d_mediawiki_jobchron',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
    }

    service::gitupdate { 'jobrunner':
        dir     => $dir,
        restart => $restart,
    }

    service::gitupdate { 'jobchron':
        dir     => $dir,
        pull    => false,
        restart => $restart,
    }

    service { 'jobrunner':
        ensure   => $ensure,
        enable   => $enable,
        provider => 'upstart',
        require  => Mediawiki::Wiki[$::mediawiki::wiki_name],
    }

    service { 'jobchron':
        ensure   => $ensure,
        enable   => $enable,
        provider => 'upstart',
        require  => Mediawiki::Wiki[$::mediawiki::wiki_name],
    }
}
