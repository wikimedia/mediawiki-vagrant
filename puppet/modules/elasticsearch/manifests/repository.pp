# == Class: Elasticsearch::Repository
#
# Configure an atp repository to fetch elasticsearch packages from.
class elasticsearch::repository {
    apt::repository { 'wikimedia-elastic':
        uri        => 'http://apt.wikimedia.org/wikimedia',
        dist       => "${::lsbdistcodename}-wikimedia",
        components => 'component/elastic55 thirdparty/elastic55',
    }
}
