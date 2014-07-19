# == Class: mediawiki::jobrunner
#
# jobrunner continuously processes the MediaWiki job queue by dispatching
# workers to perform tasks and monitoring their success or failure.
#
class mediawiki::jobrunner {
    git::clone { 'mediawiki/services/jobrunner':
        directory => '/srv/jobrunner',
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
        source => 'puppet:///modules/mediawiki/jobrunner.conf',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        notify => Service['jobrunner'],
    }

    file { '/etc/jobrunner.ini':
        source => 'puppet:///modules/mediawiki/jobrunner.ini',
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        notify => Service['jobrunner'],
    }

    file { '/etc/logrotate.d/mediawiki_jobrunner':
        source  => 'puppet:///modules/mediawiki/logrotate.d_mediawiki_jobrunner',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    service { 'jobrunner':
        ensure   => 'running',
        provider => 'upstart',
        require  => Exec['mediawiki_setup'],
    }
}
