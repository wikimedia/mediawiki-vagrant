# == Class: role::cirrussearch
# The CirrusSearch extension implements searching for MediaWiki using
# Elasticsearch.
class role::cirrussearch (
    $public_url,
) {
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

    # The eventbus role sets up the EventGate service, to which
    # Monolog + the EventBus extension use to log to Kafka.
    include ::role::eventbus

    # Elasticsearch plugins (for search)
    $es_package = $::elasticsearch::repository::es_package
    $plugins_version = $::elasticsearch::repository::es_plugins_version
    file { '/tmp/wmf-elasticsearch-search-plugins.deb':
        ensure => present,
        source => "https://apt.wikimedia.org/wikimedia/pool/component/${es_package}/w/wmf-elasticsearch-search-plugins/wmf-elasticsearch-search-plugins_${plugins_version}_all.deb",
        owner  => root,
        group  => root,
        mode   => '0444',
    }

    package { 'wmf-elasticsearch-search-plugins':
        ensure   => installed,
        provider => dpkg,
        source   => '/tmp/wmf-elasticsearch-search-plugins.deb',
        before   => Service['elasticsearch'],
    }

    mediawiki::wiki { 'cirrustest': }

    mediawiki::extension { 'Elastica':
        composer => true,
    }

    mediawiki::extension { 'CirrusSearch':
        settings => template('elasticsearch/CirrusSearch.php.erb'),
        require  => [
            Service['elasticsearch'],
            Class['eventschemas'],
        ],
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

    $es_version = regsubst( $::elasticsearch::repository::es_version, '^(\d+\.\d+).+$', '\1' )
    mediawiki::import::text { 'VagrantRoleCirrusSearch':
        content => template('role/cirrussearch/VagrantRoleCirrusSearch.wiki.erb'),
    }
}
