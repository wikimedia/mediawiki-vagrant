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
        group   => 'elasticsearch',
        name    => 'elasticsearch-analysis-icu',
        version => '2.1.0',
    }
    elasticsearch::plugin { 'kuromoji':
        group   => 'elasticsearch',
        name    => 'elasticsearch-analysis-kuromoji',
        version => '2.1.0',
    }
    elasticsearch::plugin { 'stempel':
        group   => 'elasticsearch',
        name    => 'elasticsearch-analysis-stempel',
        version => '2.1.0',
    }
    elasticsearch::plugin { 'smartcn':
        group   => 'elasticsearch',
        name    => 'elasticsearch-analysis-smartcn',
        version => '2.1.0',
    }
    elasticsearch::plugin { 'hebrew':
        group   => 'elasticsearch',
        name    => 'elasticsearch-analysis-hebrew',
        version => '1.1',
        url     => 'http://dl.bintray.com/synhershko/HebMorph/elasticsearch-analysis-hebrew-1.1.zip'
    }
    ## Highlighter
    elasticsearch::plugin { 'highlighter':
        group   => 'org.wikimedia.search.highlighter',
        name    => 'experimental-highlighter-elasticsearch-plugin',
        version => '0.0.6',
    }

    mediawiki::extension { 'Elastica': }

    mediawiki::extension { 'CirrusSearch':
        settings => template('elasticsearch/CirrusSearch.php.erb'),
        require  => Service['elasticsearch'],
    }

    vagrant::settings { 'cirrussearch':
        ram           => 1536,
        forward_ports => { 9200 => 9200 },
    }

    exec { 'build CirrusSearch search index':
        command => 'php ./maintenance/updateSearchIndexConfig.php --startOver && php ./maintenance/forceSearchIndex.php',
        onlyif  => 'php ./maintenance/cirrusNeedsToBeBuilt.php --quiet',
        cwd     => '/vagrant/mediawiki/extensions/CirrusSearch',
        require => Mediawiki::Extension['CirrusSearch']
    }
}
