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
# [*verbose*]
#   Enable verbose logging.
#
# [*groups*]
#   Runner group configuration
#
class mediawiki::jobrunner(
    $enable,
    $dir,
    $verbose,
    $groups,
) {
    require ::mediawiki

    $ensure = $enable ? {
        false   => 'absent',
        default => 'present',
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
        content => template('mediawiki/jobrunner.default.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        notify  => [
            Service['jobrunner'],
            Service['jobchron'],
        ],
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

    systemd::service { 'jobrunner':
        ensure  => $ensure,
        require => Mediawiki::Wiki[$::mediawiki::wiki_name],
    }

    systemd::service { 'jobchron':
        ensure  => $ensure,
        require => Mediawiki::Wiki[$::mediawiki::wiki_name],
    }
}
