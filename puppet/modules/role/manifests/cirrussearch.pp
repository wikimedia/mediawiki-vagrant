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
    require ::service

    # Elasticsearch plugins
    ## Analysis
    elasticsearch::plugin { 'analysis-icu':
        core => true,
    }

    # Not enabled on production wikis
    elasticsearch::plugin { 'analysis-kuromoji':
        ensure => absent,
    }

    # Not enabled on production wikis
    elasticsearch::plugin { 'analysis-stempel':
        ensure => absent,
    }

    # Not enabled on production wikis
    elasticsearch::plugin { 'analysis-smartcn':
        ensure => absent,
    }
    elasticsearch::plugin { 'elasticsearch-analysis-hebrew':
        # Less stable then icu plugin
        ensure => absent,
    }
    ## Highlighter
    elasticsearch::plugin { 'experimental-highlighter-elasticsearch-plugin':
        group  => 'org.wikimedia.search.highlighter',
        esname => 'experimental-highlighter',
    }
    ## Trigram accelerated regular expressions, "safer" query, and friends
    elasticsearch::plugin { 'extra':
        group => 'org.wikimedia.search',
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
