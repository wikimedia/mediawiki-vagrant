# == Define: git::install
#
# Creates a git clone of a specified wikimedia project into a directory,
# and checks out the specfied commit.
#
# === Parameters
#
# [*directory*]
#   Path to clone the repository into.
#
# [*commit*]
#   The commit to checkout in the repository. This can specify a commit by
#   hash (short or full), a tag or a tree.
#
# [*remote*]
#   Remote URL for the repository. If unspecified, the resource title
#   will be interpolated into $git::urlformat.
#
# [*owner*]
#   User that should own the checked out repository. Git commands will run as
#   this user so the user must have the ability to create the target
#   directory. Default 'root'.
#
# [*group*]
#   Group that should own the checked out repostory. Default 'root'.
#
# [*preserve_commit*]
#   Keep the working copy at the specified commit. Default true.
#
# === Example usage
#
#   git::install { 'project/name/on/gerrit':
#       directory     => '/some/path/here',
#       commit        => 'tags/my-preferred-tag',
#       post_checkout => 'puppet://files/some/script/that/should/run/post/checkout'
#   }
#
define git::install(
    $directory,
    $commit,
    $remote          = undef,
    $owner           = 'root',
    $group           = 'root',
    $preserve_commit = true,
) {
    require ::git

    git::clone { $title:
        directory => $directory,
        owner     => $owner,
        group     => $group,
        remote    => $remote,
        notify    => Exec["git_install_checkout_${title}"],
    }

    exec { "git_install_checkout_${title}":
        command     => "/usr/bin/git remote update && /usr/bin/git checkout ${commit}",
        cwd         => $directory,
        user        => $owner,
        refreshonly => true
    }

    if $preserve_commit {
        exec { "git_install_reset_${title}":
            command => '/usr/bin/git clean -d --force & /usr/bin/git checkout -- .',
            cwd     => $directory,
            user    => $owner,
            unless  => "/usr/bin/git diff HEAD..${commit} --exit-code",
            notify  => Exec["git_install_checkout_${title}"],
            require => Git::Clone[$title],
        }
    }
}
