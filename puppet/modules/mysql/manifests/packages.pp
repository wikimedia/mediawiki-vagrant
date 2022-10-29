# == Class: mysql::packages
#
# MySQL package resources, abstracted out to a separate, unparametrized
# class so they can be included from multiple locations.
#
class mysql::packages {
    # needed by command line client
    require_package('less')

    package { 'mariadb-server':
        ensure => present,
    }
}
