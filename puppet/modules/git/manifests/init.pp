# == Class: git
#
# Base class for using Puppet to clone and manage Git repositories.
#
# === Parameters
#
# [*urlformat*]
#   When a 'git::clone'' resource does not define a 'remote' parameter,
#   the remote repository URL is constructed by interpolating the title
#   of the resource into the format string below. This provides a
#   convenient syntactic sugar for cloning Gerrit repositories.
#   Default: 'https://gerrit.wikimedia.org/r/p/%s.git'.
#
# [*default_depth*]
#   Default depth for git clones. If specified, creates a shallow clone with
#   history truncated to the specified number of revisions. Default undef.
#
# === Examples
#
#  # Use GitHub as the default remote for repositories.
#  class { 'git':
#    urlformat => 'https://github.com/%s.git',
#  }
#
class git(
    $urlformat = 'https://gerrit.wikimedia.org/r/p/%s.git',
    $default_depth = undef,
) {
    include ::git::gerrit

    $packages = [
        'git',
        'git-man',
    ]

    package { $packages:
        ensure  => 'present',
    }

    package { 'git-review':
        ensure   => '1.25.0',
        provider => 'pip',
    }
}
