# == Class: env
#
# This lightweight Puppet module is used to manage the configuration of
# shell environments.
#
class env {
    file { '/etc/profile.d/puppet-managed.sh':
        source => 'puppet:///modules/env/puppet-managed.sh',
        mode   => '0755',
    }

    file { '/etc/profile.d/puppet-managed':
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/env/profile.d-empty',
    }

    File['/etc/profile.d/puppet-managed'] -> Env::Profile <| |>
}
