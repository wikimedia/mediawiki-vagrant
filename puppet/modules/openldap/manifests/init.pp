# == Class: openldap
#
# This class installs slapd and configures it with a single suffix hdb
# database. The implementation here is tuned to work with ::role::ldapauth and
# should not be mistaken for a reusable Puppet module.
#
# Based loosely on the openldap class from
# https://phabricator.wikimedia.org/diffusion/OPUP/
#
# === Parameters
#
# [*suffix*]
#   Distinguished name of the root of the subtree managed by this server.
#
# [*datadir*]
#   The datadir this suffix will be installed, e.g. "/var/lib/ldap"
#
# [*admin_dn*]
#   Distinguished name of admin user.
#
# [*admin_password*]
#   Password for admin user.
#
# [*logging*]
#   Specify the kind of logging desired. Defaults to "sync stats" And it is
#   not named loglevel cause that's a puppet metaparameter
#
class openldap(
    $suffix,
    $datadir,
    $admin_dn,
    $admin_password,
    $logging = 'sync stats',
) {
    require_package('slapd', 'ldap-utils', 'python-ldap')

    # Remove the package provided ldap-based config system so that we can just
    # hardcode the config in /etc/ldap/slapd.conf
    exec { 'rm_slapd.d':
        onlyif  => '/usr/bin/test -d /etc/ldap/slapd.d',
        command => '/bin/rm -rf /etc/ldap/slapd.d',
        require => Package['slapd'],
    }

    file { $datadir:
        ensure  => directory,
        recurse => false,
        owner   => 'openldap',
        group   => 'openldap',
        mode    => '0750',
        force   => true,
        require => Package['slapd'],
    }

    file { '/etc/ldap/schema/rfc2307bis.schema':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        source  => 'puppet:///modules/openldap/rfc2307bis.schema',
        require => Package['slapd'],
        notify  => Service['slapd'],
    }

    file { '/etc/ldap/schema/openssh-ldap.schema':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        source  => 'puppet:///modules/openldap/openssh-ldap.schema',
        require => Package['slapd'],
        notify  => Service['slapd'],
    }

    file { '/etc/ldap/schema/sudo.schema':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        source  => 'puppet:///modules/openldap/sudo.schema',
        require => Package['slapd'],
        notify  => Service['slapd'],
    }

    file { '/etc/ldap/slapd.conf' :
        ensure  => present,
        owner   => 'openldap',
        group   => 'openldap',
        mode    => '0440',
        content => template('openldap/slapd.erb'),
        require => Package['slapd'],
        notify  => Service['slapd']
    }

    file { '/etc/default/slapd' :
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('openldap/default.erb'),
        require => Package['slapd'],
        notify  => Service['slapd']
    }

    file { '/etc/ldap/ldap.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('openldap/ldap.conf.erb'),
        require => Package['slapd'],
    }

    service { 'slapd':
        ensure     => running,
        hasstatus  => true,
        hasrestart => true,
        require    => [
            Exec['rm_slapd.d'],
            File[$datadir],
            File['/etc/ldap/ldap.conf'],
        ]
    }
}
