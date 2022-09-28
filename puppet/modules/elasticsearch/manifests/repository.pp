# == Class: Elasticsearch::Repository
#
# Configure an apt repository to fetch elasticsearch packages from.
class elasticsearch::repository (
    $es_package,
    $es_version,
    $es_plugins_version,
) {
    apt::repository { 'wikimedia-elastic':
        uri        => 'http://apt.wikimedia.org/wikimedia',
        dist       => "${::lsbdistcodename}-wikimedia",
        components => "component/${es_package} thirdparty/${es_package}",
    }

    # WMF repo above doesn't serve arm64-compatible PHP packages;
    # this alternative does
    $es_major_version = regsubst( $es_version, '^(\d+).+$', '\1' )
    apt::repository { 'elastic-elastic':
        uri        => "https://artifacts.elastic.co/packages/oss-${es_major_version}.x/apt",
        dist       => 'stable',
        components => 'main',
        keyfile    => 'puppet:///modules/elasticsearch/elasticsearch-pubkey.asc',
    }
}
