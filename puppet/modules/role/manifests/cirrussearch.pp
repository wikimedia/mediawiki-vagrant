# == Class: role::cirrussearch
# The CirrusSearch extension implements searching for MediaWiki using
# Elasticsearch.
class role::cirrussearch {
    include ::role::commons
    include ::role::timedmediahandler
    include ::role::pdfhandler
    include ::role::cite
    include ::elasticsearch
    include ::eventschemas
    # Utilized as part of cirrus logging infrastructure
    include ::role::psr3
    include ::role::kafka
    # not strictly required for cirrussearch, but used in the tests
    include ::role::svg
    include ::role::sitematrix
    # necessary for CirrusSearch.php.erb to point to service root dir
    include ::service
    include ::role::langwikis

    # Elasticsearch plugins (for search)
    package { 'wmf-elasticsearch-search-plugins':
        ensure => latest,
        before => Service['elasticsearch'],
    }

    # TODO: remove hack once elasticsearch 6 is well establshed
    # The reason we need this is that when we migrate from elasticsearch 5
    # to elasticsearch-oss 6 the plugin directory is emptied
    # call apt --reinstall to make sure the plugins are reinstalled
    exec { 'fix-plugins':
        command => 'apt-get install --reinstall wmf-elasticsearch-search-plugins',
        creates => '/usr/share/elasticsearch/plugins/extra',
        require => Package['wmf-elasticsearch-search-plugins']
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
