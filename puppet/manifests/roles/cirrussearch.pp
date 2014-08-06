# == Class: role::cirrussearch
# The CirrusSearch extension implements searching for MediaWiki using
# Elasticsearch.
class role::cirrussearch {
    include role::mediawiki
    include role::timedmediahandler
    include role::pdfhandler
    include role::cite

    include packages::jq

    class { '::elasticsearch': }

    # Elasticsearch plugins
    ## Analysis
    elasticsearch::plugin { 'icu':
        name    => 'elasticsearch-analysis-icu',
        version => '2.2.0',
    }
    elasticsearch::plugin { 'kuromoji':
        name    => 'elasticsearch-analysis-kuromoji',
        version => '2.2.0',
    }
    elasticsearch::plugin { 'stempel':
        name    => 'elasticsearch-analysis-stempel',
        version => '2.2.0',
    }
    elasticsearch::plugin { 'smartcn':
        name    => 'elasticsearch-analysis-smartcn',
        version => '2.1.0',
    }
    elasticsearch::plugin { 'hebrew':
        # Less stable then icu plugin
        ensure  => 'absent',
        name    => 'elasticsearch-analysis-hebrew',
    }
    ## Highlighter
    elasticsearch::plugin { 'highlighter':
        group   => 'org.wikimedia.search.highlighter',
        name    => 'experimental-highlighter-elasticsearch-plugin',
        version => '0.0.10',
    }

    mediawiki::extension { 'Elastica': }

    mediawiki::extension { 'CirrusSearch':
        settings => template('elasticsearch/CirrusSearch.php.erb'),
        require  => Service['elasticsearch'],
    }

    vagrant::settings { 'cirrussearch':
        ram           => 2000,
        forward_ports => { 9200 => 9200 },
    }

    exec { 'build_search_index':
        command => 'php5 maintenance/updateSearchIndexConfig.php --startOver && php5 maintenance/forceSearchIndex.php',
        onlyif  => 'php5 maintenance/cirrusNeedsToBeBuilt.php --quiet',
        cwd     => "${mediawiki::dir}/extensions/CirrusSearch",
        user    => 'www-data',
        require => [
            Mediawiki::Extension['CirrusSearch'],
            Exec['update_database'],
        ]
    }
}
