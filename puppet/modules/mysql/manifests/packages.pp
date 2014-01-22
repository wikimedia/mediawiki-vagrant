# == Class: mysql::packages
#
# MySQL package resources, abstracted out to a separate, unparametrized
# class so they can be included from multiple locations.
#
class mysql::packages {
    package { 'mysql-server':
        ensure => present,
    }
}
