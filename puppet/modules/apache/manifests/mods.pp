# == Class: apache::mods
#
# This module contains unparametrized classes that wrap some popular
# Apache mods. Because the classes are not parametrized, they may be
# included multiple times without causing duplicate definition errors.
#

# mod_rewrite
class apache::mods::rewrite {
    apache::mod { 'rewrite': }
}

# mod_alias
class apache::mods::alias {
    apache::mod { 'alias': }
}

# mod_php5
class apache::mods::php5 {
    apache::mod { 'php5': }
}

# mod_wsgi
class apache::mods::wsgi {
    package { 'libapache2-mod-wsgi':
        ensure => present,
    }

    apache::mod { 'wsgi':
        require => Package['libapache2-mod-wsgi'],
    }
}
