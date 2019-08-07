# == Class: Elasticsearch::Repository
#
# Configure an apt repository to fetch elasticsearch packages from.
class elasticsearch::repository (
    $es_package,
    $es_version,
) {
    apt::repository { 'wikimedia-elastic':
        uri        => 'http://apt.wikimedia.org/wikimedia',
        dist       => "${::lsbdistcodename}-wikimedia",
        components => "component/${es_package} thirdparty/${es_package}",
    }
}
