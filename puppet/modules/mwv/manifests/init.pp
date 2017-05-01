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
#   /etc/ directory to use for storing MW-Vagrant-specific configuration files
#   which need not to be shared with the host (example: '/etc/mw-vagrant').
#
# [*services_dir*]
#   Root directory for provisioning new services to use in the VM
#
# [*vendor_dir*]
#   Root directory for provisioning 3rd party services (eg Redis storage)
#
# [*tld*]
#   Top level domain to use when creating hostnames. Value should include
#   leading '.' (example: '.local.wmftest.net').
#
class mwv (
    $files_dir,
    $etc_dir,
    $services_dir,
    $vendor_dir,
    $tld,
) {
    include ::apt
    include ::env
    include ::git
    include ::mwv::packages
    include ::mwv::cachefilesd

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

}
