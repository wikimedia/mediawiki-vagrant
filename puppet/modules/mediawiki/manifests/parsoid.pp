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
#   Install Parsoid to this directory.
#
# [*port*]
#   The Parsoid web service will listen on this port.
#
# [*use_php_preprocessor*]
#   If true, use the PHP pre-processor to expand templates via the
#   MediaWiki API.
#
# [*use_selser*]
#   Use selective serialization.
#
# [*allow_cors*]
#   Domains that should be permitted to make cross-domain requests.
#   If false or undefined, disables CORS.
#
# [*workers*]
#   Number of worker processes to fork.
#
# === Examples
#
#  class { 'mediawiki::parsoid':
#    port => 8100,
#  }
#
class mediawiki::parsoid(
    $dir,
    $port,
    $use_php_preprocessor,
    $use_selser,
    $allow_cors,
    $workers,
) {
    include ::mediawiki

    package { [ 'nodejs', 'nodejs-legacy' ]: }

    git::clone { 'mediawiki/services/parsoid/deploy':
        directory  => $dir,
        require    => Package['nodejs', 'nodejs-legacy'],
    }

    file { 'localsettings.js':
        path    => "${dir}/src/api/localsettings.js",
        content => template('mediawiki/parsoid.localsettings.js.erb'),
        require => Git::Clone['mediawiki/services/parsoid/deploy'],
    }

    file { '/etc/init/parsoid.conf':
        content => template('mediawiki/parsoid.conf.erb'),
        require => Package['nodejs', 'nodejs-legacy'],
    }

    mediawiki::extension { 'Parsoid':
        entrypoint => 'php/Parsoid.php',
        settings   => { wgParsoidCacheServers => [], },
    }

    service { 'parsoid':
        ensure    => running,
        provider  => 'upstart',
        subscribe => File['localsettings.js', '/etc/init/parsoid.conf'],
    }
}
