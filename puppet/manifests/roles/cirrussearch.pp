# == Class: role::cirrussearch
# The CirrusSearch extension implements searching for MediaWiki using
# Elasticsearch.
class role::cirrussearch {
    include role::mediawiki
    include role::timedmediahandler
    include role::pdfhandler
    include role::cite

    class { '::elasticsearch': }

    mediawiki::extension { 'Elastica': }

    mediawiki::extension { 'CirrusSearch':
        settings => template('elasticsearch/CirrusSearch.php.erb'),
        require  => Service['elasticsearch'],
    }

    exec { 'build CirrusSearch search index':
        command     => 'php ./maintenance/updateSearchIndexConfig.php && php ./maintenance/forceSearchIndex.php && touch .indexed',
        creates     => '/vagrant/mediawiki/extensions/CirrusSearch/.indexed',
        cwd         => '/vagrant/mediawiki/extensions/CirrusSearch',
        require     =>  Mediawiki::Extension['CirrusSearch'],
    }

    notice('If you want to debug Elasticsearch queries you should forward port 9200 from the VM.  See supprt/Vagrantfile-extra.rb for instructions.')
}
