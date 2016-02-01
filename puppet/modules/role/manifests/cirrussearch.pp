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
    include ::role::kafka
    # not strictly required for cirrussearch, but used in the tests
    include ::role::svg
    # necessary for CirrusSearch.php.erb to point to service root dir
    require ::service

    # By default Vagrant sets up firefox as the global browsertest
    # runner, we want to ensure phantomjs is available for running the
    # cirrussearch tests in a headless and parallelized manner.
    require_package('phantomjs')

    # Elasticsearch plugins
    ## Analysis
    elasticsearch::plugin { 'icu':
        name    => 'elasticsearch-analysis-icu',
        version => '2.7.0',
    }
    elasticsearch::plugin { 'kuromoji':
        name    => 'elasticsearch-analysis-kuromoji',
        version => '2.7.0',
    }
    elasticsearch::plugin { 'stempel':
        name    => 'elasticsearch-analysis-stempel',
        version => '2.7.0',
    }
    elasticsearch::plugin { 'smartcn':
        name    => 'elasticsearch-analysis-smartcn',
        version => '2.7.0',
    }
    elasticsearch::plugin { 'hebrew':
        # Less stable then icu plugin
        ensure => 'absent',
        name   => 'elasticsearch-analysis-hebrew',
    }
    ## Highlighter
    elasticsearch::plugin { 'highlighter':
        group   => 'org.wikimedia.search.highlighter',
        name    => 'experimental-highlighter-elasticsearch-plugin',
        version => '1.7.0',
    }
    ## Trigram accelerated regular expressions, "safer" query, and friends
    elasticsearch::plugin { 'extra':
        group   => 'org.wikimedia.search',
        name    => 'extra',
        version => '1.7.1',
    }
    ## Language detection plugin ( built from https://github.com/jprante/elasticsearch-langdetect )
    elasticsearch::plugin { 'langdetect':
        group   => 'org.xbib.elasticsearch.plugin',
        name    => 'elasticsearch-langdetect',
        version => '1.7.0.0',
        url     => 'https://archiva.wikimedia.org/repository/releases/org/xbib/elasticsearch/plugin/elasticsearch-langdetect/1.7.0.0/elasticsearch-langdetect-1.7.0.0.zip'
    }

    mediawiki::wiki { 'cirrustest': }

    mediawiki::extension { 'Elastica':
        composer => true,
    }

    mediawiki::extension { 'CirrusSearch':
        settings      => template('elasticsearch/CirrusSearch.php.erb'),
        require       => [
            Service['elasticsearch'],
            Git::Clone['mediawiki/event-schemas']
        ],
        browser_tests => 'tests/browser',
    }

    mediawiki::settings { 'cirrustest:cirrussearch test suite':
        values => template('elasticsearch/CirrusSearchTest.php.erb'),
    }

    mediawiki::settings { 'commons:cirrussearch':
        values => template('elasticsearch/CirrusSearch-commons.php.erb'),
    }

    exec { 'build_search_index':
        command => '/usr/local/bin/foreachwiki extensions/CirrusSearch/maintenance/updateSearchIndexConfig.php --startOver && /usr/local/bin/foreachwiki extensions/CirrusSearch/maintenance/forceSearchIndex.php',
        onlyif  => '/usr/local/bin/mwscript extensions/CirrusSearch/maintenance/cirrusNeedsToBeBuilt.php --quiet',
        user    => 'www-data',
        require => [
            Class['::mediawiki::multiwiki'],
            Mediawiki::Extension['CirrusSearch'],
            Exec['update_all_databases'],
        ]
    }
}
