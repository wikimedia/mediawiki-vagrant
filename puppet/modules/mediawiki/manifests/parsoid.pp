# == Class: mediawiki::parsoid
#
# Parsoid is a wiki runtime which can translate back and forth between
# MediaWiki's wikitext syntax and an equivalent HTML / RDFa document model with
# better support for automated processing and visual editing. Its main user
# currently is the visual editor project.
#
# === Parameters
#
# [*dir*]
#   Install Parsoid to this directory (default: '/srv/parsoid').
#
# [*port*]
#   The Parsoid web service will listen on this port.
#
# [*use_php_preprocessor*]
#   If true, use the PHP pre-processor to expand templates via the
#   MediaWiki API (default: true).
#
# [*use_selser*]
#   Use selective serialization (default: false).
#
# [*allow_cors*]
#   Domains that should be permitted to make cross-domain requests
#   (default: '*'). If false or undefined, disables CORS.
#
# === Examples
#
#  class { 'mediawiki::parsoid':
#    port => 8100,
#  }
#
class mediawiki::parsoid(
    $dir                  = '/srv/parsoid',
    $port                 = 8000,
    $use_php_preprocessor = true,
    $use_selser           = true,
    $allow_cors           = '*',
) {
    include mediawiki

    package { 'nodejs':
        ensure => '0.8.2-1chl1~precise1',
    }

    git::clone { 'mediawiki/services/parsoid/deploy':
        directory  => $dir,
        require    => Package['nodejs'],
    }

    file { 'localsettings.js':
        path    => "${dir}/src/api/localsettings.js",
        content => template('mediawiki/parsoid.localsettings.js.erb'),
        require => Git::Clone['mediawiki/services/parsoid/deploy'],
        notify  => Service['parsoid'],
    }

    file { '/etc/init/parsoid.conf':
        ensure  => present,
        content => template('mediawiki/parsoid.conf.erb'),
        require => Package['nodejs'],
    }

    mediawiki::extension { 'Parsoid':
        # https://bugzilla.wikimedia.org/show_bug.cgi?id=64644
        entrypoint => 'php/Parsoid.php',
        settings   => {
            # Documented to be used for Varnish, which is not yet on MediaWiki-Vagrant
            wgParsoidCacheServers => [],
        }
    }

    service { 'parsoid':
        ensure    => running,
        provider  => 'upstart',
        require   => File['localsettings.js', '/etc/init/parsoid.conf'],
    }
}
