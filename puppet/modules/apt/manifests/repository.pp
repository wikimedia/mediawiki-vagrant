# == Define: apt::repository
#
# Add an apt repository via an /etc/apt/sources.list.d/ config file.
#
# Based on Wikimedia's apt::repository
#
# Note: if you try to use apt::repository and require_package() in the same
# manifest you will ends up making a circular dep on Exec['apt-get update'].
# The fix for this is to separate them into independent classes (like X::repo
# and X::packages).
#
# === Parameters
#
# [*uri*]
#   URI to repo
#
# [*dist*]
#   Distribution
#
# [*components*]
#   Components to install from this repo
#
# [*source*]
#   Add deb-src line? Default false.
#
# [*keyfile*]
#   GPG key used to sign packages in this repo. Default undef.
#
# [*can_trust*]
#   Should this repo be trusted for installing unsinged packages?
#   Default false.
#
# [*comment_old*]
#   Comment out matching lines in /etc/apt/sources.list. Default false.
#
# [*ensure*]
#   Ensure present/absent. Default present.
#
define apt::repository (
    $uri,
    $dist,
    $components,
    $source      = true,
    $keyfile     = undef,
    $can_trust   = false,
    $comment_old = false,
    $ensure      = 'present',
) {
    $trust = $can_trust ? {
        true    => '[trusted=yes] ',
        default => '',
    }

    $binline = "deb ${trust}${uri} ${dist} ${components}\n"
    $srcline = $source ? {
        true    => "deb-src ${uri} ${dist} ${components}\n",
        default => '',
    }

    file { "/etc/apt/sources.list.d/${name}.list":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => "${binline}${srcline}",
        notify  => Exec['apt-get update'],
    }

    if $keyfile {
        file { "/var/lib/apt/keys/${name}.gpg":
            ensure => present,
            owner  => 'root',
            group  => 'root',
            mode   => '0400',
            source => $keyfile,
            before => File["/etc/apt/sources.list.d/${name}.list"],
        }

        exec { "/usr/bin/apt-key add /var/lib/apt/keys/${name}.gpg":
            subscribe   => File["/var/lib/apt/keys/${name}.gpg"],
            refreshonly => true,
        }
    }

    if $comment_old {
        $escuri = regsubst(regsubst($uri, '/', '\/', 'G'), '\.', '\.', 'G')
        $binre = "deb(-src)?\s+${escuri}\s+${dist}\s+${components}"

        # comment out the old entries in /etc/apt/sources.list
        exec { "apt-${name}-sources":
            command => "/bin/sed -ri '/${binre}/s/^deb/#deb/' /etc/apt/sources.list",
            creates => "/etc/apt/sources.list.d/${name}.list",
            before  => File["/etc/apt/sources.list.d/${name}.list"],
        }
    }
}
