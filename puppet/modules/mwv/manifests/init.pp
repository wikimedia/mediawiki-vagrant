# == Class: mwv
#
# General settings and configuration for mediawiki-vagrant deployments
#
# === Parameters
#
# [*files_dir*]
#   Root directory for general file storage
#
# [*services_dir*]
#   Root directory for provisioning new services to use in the VM
#
# [*vendor_dir*]
#   Root directory for provisioning 3rd party services (eg Redis storage)
#
class mwv (
    $files_dir,
    $services_dir,
    $vendor_dir,
) {
    include ::apt
    include ::env
    include ::git

    file { $vendor_dir:
        owner => 'root',
        group => 'root',
        mode  => '0755',
    }

    # Ensure the uid/gid used for shared files exists in the VM
    if $::share_group =~ /^\d+$/ {
        group { 'vagrant_share':
            ensure    => 'present',
            gid       => $::share_group,
            allowdupe => true,
        } -> File <| |>
    }
    if $::share_owner =~ /^\d+$/ {
        user { 'vagrant_share':
            ensure    => 'present',
            uid       => $::share_owner,
            gid       => $::share_group,
            allowdupe => true,
        } -> File <| |>
    }

    package { 'python-pip': } -> Package <| provider == pip |>

    # Install common development tools
    package { [ 'build-essential', 'python-dev', 'ruby-dev' ]: }

    # Remove chef if it is installed in the base image
    # Bug: 67693
    package { [ 'chef', 'chef-zero' ]:
      ensure => absent,
    }

    # Support the `nfs_cache` setting with cachefilesd
    package { 'cachefilesd':
        ensure => present,
    }

    file { '/etc/default/cachefilesd':
        content => "RUN=yes\nSTARTTIME=5\n",
        require => Package['cachefilesd'],
    }

    service { 'cachefilesd':
        ensure    => running,
        require   => Package['cachefilesd'],
        subscribe => File['/etc/default/cachefilesd'],
    }
}
