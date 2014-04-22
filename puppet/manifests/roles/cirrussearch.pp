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
    ## Highlighter
    elasticsearch::plugin { 'highlighter':
        group   => 'org.wikimedia.search.highlighter',
        name    => 'experimental-highlighter-elasticsearch-plugin',
        version => '0.0.3',
    }

    mediawiki::extension { 'Elastica': }

    mediawiki::extension { 'CirrusSearch':
        settings => template('elasticsearch/CirrusSearch.php.erb'),
        require  => Service['elasticsearch'],
    }

    vagrant::settings { 'cirrussearch':
        ram           => 1024,
        forward_ports => { 9200 => 9200 },
    }

    exec { 'build CirrusSearch search index':
        command => 'php ./maintenance/updateSearchIndexConfig.php && php ./maintenance/forceSearchIndex.php',
        unless  => '[ $(curl -s localhost:9200/_count | jq ".count") -gt "0" ]',
        cwd     => '/vagrant/mediawiki/extensions/CirrusSearch',
        require => [
            Mediawiki::Extension['CirrusSearch'],
            Package['curl'],
            Package['jq']
        ]
    }
}
