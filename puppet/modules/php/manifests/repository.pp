# == Class: Php::Repository
#
# Configure an apt repository to fetch php packages from.
class php::repository {
    apt::repository { 'wikimedia-php':
        uri        => 'http://apt.wikimedia.org/wikimedia',
        dist       => "${::lsbdistcodename}-wikimedia",
        components => 'component/php74',
    }
}
