# == Class virtualenv
# Helper class to install python packages via virtualenv.
# Require this class, then use virtualenv::environment.
#
class virtualenv {
    package { 'virtualenv':
        ensure   => present,
        provider => pip,
    }

    # cleanup old workaround for T266737
    apt::repository { 'wikimedia-pyall':
        ensure => absent,
        uri        => 'htdtps://apt.wikimedia.org/wikimedia',
        dist       => "${::lsbdistcodename}-wikimedia",
        components => 'component/pyall',
        keyfile    => 'puppet:///modules/apt/wikimedia-pubkey.asc',
    }
}

