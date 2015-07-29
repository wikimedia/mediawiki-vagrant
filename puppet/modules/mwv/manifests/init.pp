# == Class: mwv
#
# General settings and configuration for mediawiki-vagrant deployments
#
# === Parameters
#
# [*files_dir*]
#   Root directory for general file storage
#
# [*etc_dir*]
#
#   /etc/ directory to use for storing MW-Vagrant-specific configuration files
#   which need not to be shared with the host (example: '/etc/mw-vagrant').
#
# [*services_dir*]
#   Root directory for provisioning new services to use in the VM
#
# [*vendor_dir*]
#   Root directory for provisioning 3rd party services (eg Redis storage)
#
# [*enable_cachefilesd*]
#   Enable cachefilesd service
#
class mwv (
    $files_dir,
    $etc_dir,
    $services_dir,
    $vendor_dir,
    $enable_cachefilesd,
) {
    include ::apt
    include ::env
    include ::git

    file { $etc_dir:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
    }

    file { $vendor_dir:
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
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

    if $enable_cachefilesd {
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
    } else {
        # Cleanup cachefilesd if param has been toggled
        package { 'cachefilesd':
            ensure => absent,
        }
    }
}
