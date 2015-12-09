# == Define: cgroup::config
#
# Sets up a new cgroup.
#
# === Parameters
#
# [*limits*]
#   Optional, limits for the cgroup.
#
# [*cgrules*]
#   Optional, used to tie the cgroup to a system user/group.
#
# === Examples
#
#   cgroup::config { 'thumbor':
#       limits  => 'memory { memory.limit_in_bytes = "1073741824"; }',
#       cgrules => '@thumbor memory thumbor',
#   }
#
define cgroup::config(
    $limits = undef,
    $cgrules = undef,
) {
    include ::cgroup

    unless $limits or $cgrules {
        warning('cgroup::config must specify limits and/or cgrules')
    }

    if $limits {
        file_line { "/etc/cgconfig.conf:${title}":
            line   => "group ${title} { ${limits} }\n",
            match  => "^group ${title}.*$",
            path   => '/etc/cgconfig.conf',
            notify => Exec['cgconfigparser'],
        }
    }

    if $cgrules {
        file_line { "/etc/cgrules.conf:${title}":
            line   => "${cgrules}\n",
            path   => '/etc/cgrules.conf',
            notify => Service['cgrulesengd'],
        }
    }
}
