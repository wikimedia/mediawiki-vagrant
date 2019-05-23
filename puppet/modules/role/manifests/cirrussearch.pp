# == Class: role::cirrussearch
# The CirrusSearch extension implements searching for MediaWiki using
# Elasticsearch.
class role::cirrussearch {
    include ::role::commons
    include ::role::timedmediahandler
    include ::role::pdfhandler
    include ::role::cite
    include ::elasticsearch
    # Utilized as part of cirrus logging infrastructure
    include ::role::psr3
    # not strictly required for cirrussearch, but used in the tests
    include ::role::svg
    include ::role::sitematrix
    include ::role::langwikis

    # eventbus role sets up the EventGate service, which
    # Monolog + the EventBus extension use to log to Kafka.
    include ::role::eventbus
    # This is only needed until EventGate can be included
    # by default, which is until all other MW Vagrant
    # NodeJS services are on NodeJS 10.
    # This var is used in CirrusSearch.php.erb
    $enable_eventgate = $::role::eventbus::enable_eventgate

    # Elasticsearch plugins (for search)
    package { 'wmf-elasticsearch-search-plugins':
        ensure => latest,
        before => Service['elasticsearch'],
    }

    mediawiki::wiki { 'cirrustest': }

    mediawiki::extension { 'Elastica':
        composer => true,
    }

    mediawiki::extension { 'CirrusSearch':
        settings      => template('elasticsearch/CirrusSearch.php.erb'),
        require       => [
            Service['elasticsearch'],
            Class['eventschemas'],
        ],
        browser_tests => 'tests/browser',
    }

    mediawiki::settings { 'cirrustest:cirrussearch test suite':
        values => template('elasticsearch/CirrusSearchTest.php.erb'),
    }

    mediawiki::settings { 'commons:cirrussearch':
        values => template('elasticsearch/CirrusSearch-commons.php.erb'),
    }

    file { '/usr/local/bin/is-cirrussearch-forceindex-needed':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('role/cirrussearch/is-cirrussearch-forceindex-needed.erb'),
    }

    mediawiki::maintenance { 'build_search_index':
        command => template('role/cirrussearch/build_search_index.erb'),
        onlyif  => '/usr/local/bin/is-cirrussearch-forceindex-needed',
        require => File['/usr/local/bin/is-cirrussearch-forceindex-needed'],
    }
}
