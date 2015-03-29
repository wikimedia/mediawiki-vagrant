# == Class: mediawiki::jobrunner
#
# jobrunner continuously processes the MediaWiki job queue by dispatching
# workers to perform tasks and monitoring their success or failure.
#
class mediawiki::jobrunner {
    include ::mediawiki
    require ::mediawiki::multiwiki

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
        source  => 'puppet:///modules/mediawiki/logrotate.d_mediawiki_jobrunner',
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }

    service { 'jobrunner':
        ensure   => 'running',
        provider => 'upstart',
        require  => Mediawiki::Wiki[$::mediawiki::wiki_name],
    }
}
