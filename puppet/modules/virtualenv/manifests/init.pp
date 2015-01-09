# == Class virtualenv
# Helper class to install python packages via virtualenv.
# Require this class, then use virtualenv::environment.
#
class virtualenv {
    package { 'virtualenv':
        ensure   => present,
        provider => pip,
    }
}

