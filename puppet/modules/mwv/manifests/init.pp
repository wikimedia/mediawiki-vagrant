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
# [*timezone*]
#   Timezone for the VM. (example: 'Etc/UTC')
#
class mwv (
    $files_dir,
    $etc_dir,
    $services_dir,
    $vendor_dir,
    $tld,
    $timezone,
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

    # Why is this so hard?
    $tzparts = split($timezone, '/')
    $tzarea = $tzparts[0]
    $tzzone = $tzparts[1]
    exec { 'debconf tzarea':
        command => "/bin/echo tzdata tzdata/Areas select ${tzarea} | /usr/bin/debconf-set-selections",
        unless  => "/usr/bin/debconf-get-selections | /bin/grep -q -E \"^tzdata\\s+tzdata/Areas\\s+select\\s+${tzarea}\"",
        before  => Package['tzdata'],
    }
    exec { 'debconf tzzone':
        command => "/bin/echo tzdata tzdata/Zones/${tzarea} select ${timezone} | /usr/bin/debconf-set-selections",
        unless  => "/usr/bin/debconf-get-selections | /bin/grep -q -E \"^tzdata\\s+tzdata/Zones/${tzarea}\\s+select\\s+${timezone}\"",
        before  => Package['tzdata'],
    }
    file { '/etc/localtime':
        ensure  => 'link',
        target  => "/usr/share/zoneinfo/${timezone}",
        require => Package['tzdata'],
    }
    file { '/etc/timezone':
        ensure  => 'present',
        content => $timezone,
        require => Package['tzdata'],
    }
}
