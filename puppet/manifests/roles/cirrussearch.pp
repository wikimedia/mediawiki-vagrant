# == Class: role::cirrussearch
# The CirrusSearch extension implements searching for MediaWiki using
# Elasticsearch.
class role::cirrussearch {
    include role::mediawiki

    class { '::elasticsearch': }

    mediawiki::extension { 'Elastica': }

    mediawiki::extension { 'CirrusSearch':
        settings => template('elasticsearch/CirrusSearch.php.erb'),
        require  => Service['elasticsearch'],
    }

    exec { 'update elastica submodule':
        cwd     => "${mediawiki::dir}/extensions/Elastica",
        command => 'git submodule update --init Elastica',
        require => Mediawiki::Extension['Elastica'],
        unless  => 'git submodule status Elastica | grep -q head',
        before  => Mediawiki::Extension['CirrusSearch'],
    }

    exec { 'build CirrusSearch search index':
        command     => 'php ./maintenance/updateSearchIndexConfig.php && php ./maintenance/forceSearchIndex.php && touch .indexed',
        creates     => '/vagrant/mediawiki/extensions/CirrusSearch/.indexed',
        cwd         => '/vagrant/mediawiki/extensions/CirrusSearch',
        require     =>  Mediawiki::Extension['CirrusSearch'],
    }

}
