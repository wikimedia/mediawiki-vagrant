# == Class virtualenv
# Helper class to install python packages via virtualenv.
# Require this class, then use virtualenv::environment.
#
class virtualenv {
    package { 'virtualenv':
        ensure   => present,
        provider => pip,
    }

    # https://people.debian.org/~paravoid/python-all/
    apt::repository { 'wikimedia-pyall':
        uri        => 'https://apt.wikimedia.org/wikimedia',
        dist       => "${::lsbdistcodename}-wikimedia",
        components => 'component/pyall',
        keyfile    => 'puppet:///modules/apt/wikimedia-pubkey.asc',
    }
}

