# == Define: git::clone
#
# Custom resource for cloning a remote git repository.
#
# === Parameters
#
# [*directory*]
#   Name for target directory for repository content. It should not
#   refer to an existing directory.
#
# [*branch*]
#   Name of branch to check out. Defaults to checking out the HEAD of the
#   remote repository.
#
# [*remote*]
#   Remote URL for the repository. If unspecified, the resource title
#   will be interpolated into $git::urlformat.
#
# [*temp_remote*]
#   Remote used for the checkout only (after that the remote URL will
#   be set to $remote). This is used as a workaround for T152801.
#
# [*owner*]
#   User that should own the checked out repository. Git commands will run as
#   this user so the user must have the ability to create the target
#   directory. Default $::share_owner.
#
# [*group*]
#   Group that should own the checked out repostory. Default $::share_group.
#
# [*ensure*]
#   What state the clone should be in. Valid values are `present` and
#   `latest`. Default 'present'.
#
# [*depth*]
#   If specified, creates a shallow clone with history truncated to the
#   specified number of revisions. Default undef.
#
# [*recurse_submodules*]
#   After the clone is created, initialize all submodules within, using their
#   default settings. Default true.
#
# [*options*]
#   Extra options to pass to git. Mainly intended for config options, i.e.
#   '-c foo=bar'.
# === Examples
#
#  Clone VisualEditor to MediaWiki extension path:
#
#  git::clone { 'extensions/VisualEditor':
#      directory => '/vagrant/mediawiki/extensions/VisualEditor',
#  }
#
define git::clone(
    $directory,
    $branch             = undef,
    $remote             = undef,
    $temp_remote        = undef,
    $owner              = $::share_owner,
    $group              = $::share_group,
    $ensure             = 'present',
    $depth              = $::git::default_depth,
    $recurse_submodules = true,
    $options            = '',
) {
    require ::git

    if !($ensure in ['present', 'latest']) {
        fail('ensure parameter must be present or latest.')
    }

    $repository = $remote ? {
        undef   => sprintf($git::urlformat, $title),
        default => $remote,
    }
    $temp_repository = pick($temp_remote, $repository)

    $arg_branch = $branch ? {
        undef   => '',
        default => "--branch '${branch}' --single-branch"
    }
    $arg_recurse = $recurse_submodules ? {
        true    => '--recurse-submodules',
        default => '',
    }
    $arg_depth = $depth ? {
        undef => '',
        default => "--depth=${depth}",
    }

    exec { "git_clone_${title}":
        command => "/usr/bin/git ${options} clone ${arg_recurse} ${arg_depth} ${arg_branch} ${temp_repository} ${directory}",
        cwd     => '/',
        creates => "${directory}/.git",
        user    => $owner,
        group   => $group,
        require => Package['git'],
        timeout => 0,
    }
    if ($temp_repository != $repository) {
        exec { "reset ${title} remote":
            command     => "/usr/bin/git remote set-url origin ${repository}",
            cwd         => $directory,
            user        => $owner,
            group       => $group,
            subscribe   => Exec["git_clone_${title}"],
            refreshonly => true,
        }
    }

    if (!defined(File[$directory])) {
        file { $directory:
            ensure => 'directory',
            owner  => $owner,
            group  => $group,
            before => Exec["git_clone_${title}"],
        }
    }

    if $ensure == 'latest' {
        exec { "git_pull_${title}":
            command  => "/usr/bin/git pull ${arg_recurse} ${arg_depth}",
            unless   => "/usr/bin/git fetch ${arg_depth} && /usr/bin/git diff --quiet @{upstream}",
            cwd      => $directory,
            user     => $owner,
            group    => $group,
            schedule => 'hourly',
            require  => Exec["git_clone_${title}"],
        }

        if $recurse_submodules {
            exec { "git_submodule_update_${title}":
                command     => '/usr/bin/git submodule update --init --recursive',
                cwd         => $directory,
                user        => $owner,
                group       => $group,
                refreshonly => true,
                subscribe   => Exec["git_pull_${title}"],
            }
        }
    }
}
