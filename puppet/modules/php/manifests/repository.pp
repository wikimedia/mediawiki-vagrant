# == Class: Php::Repository
#
# Configure an apt repository to fetch php packages from.
class php::repository {
    apt::repository { 'wikimedia-php':
        uri        => 'http://apt.wikimedia.org/wikimedia',
        dist       => "${::lsbdistcodename}-wikimedia",
        components => 'component/php74',
    }

    # WMF repo above doesn't serve arm64-compatible PHP packages;
    # this alternative does
    apt::repository { 'ondrej-php':
        uri        => 'https://packages.sury.org/php/',
        dist       => $::lsbdistcodename,
        components => 'main',
        keyfile    => 'puppet:///modules/php/ondrej-php-pubkey.asc',
    }
}
