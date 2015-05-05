# == Class: mediawiki::jobrunner
#
# jobrunner continuously processes the MediaWiki job queue by dispatching
# workers to perform tasks and monitoring their success or failure.
#
# === Parameters
#
# [*dir*]
#   Installation directory.
#
class mediawiki::jobrunner(
    $dir,
) {
    require ::mediawiki

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
        notify  => Service['jobrunner'],
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

    service { 'jobrunner':
        enable   => true,
        ensure   => 'running',
        provider => 'upstart',
        require  => Mediawiki::Wiki[$::mediawiki::wiki_name],
    }

    service { 'jobchron':
        enable   => true,
        ensure   => 'running',
        provider => 'upstart',
        require  => Mediawiki::Wiki[$::mediawiki::wiki_name],
    }
}
