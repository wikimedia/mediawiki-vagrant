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
#   Name of branch to check out. Defaults to 'master'.
#
# [*remote*]
#   Remote URL for the repository. If unspecified, the resource title
#   will be interpolated into $git::urlformat.
#
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
    $branch = 'master',
    $remote = undef,
    $owner  = 'vagrant',
    $group  = 'vagrant',
    $user = $::git_user,
) {
    include git

    if ( $remote ) {
        $url = $remote
        $origin = 'origin'
    } else {
        $url = sprintf($git::urlformat, $title)
        $origin = $user ? {
            ''          => 'origin',
            'anonymous' => 'origin',
            default     => 'gerrit',
        }
    }

    exec { "git clone ${title}":
        command     => "git clone --origin ${origin} --recursive --branch ${branch} ${url} ${directory}",
        creates     => "${directory}/.git",
        require     => Package['git'],
        user        => $owner,
        group       => $group,
        environment => 'HOME=/home/vagrant',
        timeout     => 0,
    }

    #
    # If remote is not set, configure the name and URL of the remote
    #
    if ( !$remote and $user ) {
        #
        # Force remote name to "origin" for anonymous git, and "gerrit" when GIT_USER is set
        #
        $badorigin = $user ? {
            'anonymous' => 'gerrit',
            default     => 'origin',
        }
        exec { "git rename ${title}: ${badorigin} -> ${origin}":
            command     => "git remote rename ${badorigin} ${origin}",
            onlyif      => "test $(git config --get branch.${branch}.remote) = '${badorigin}'",
            cwd         => $directory,
            require     => Package['git'],
            user        => $owner,
            group       => $group,
            environment => 'HOME=/home/vagrant',
            timeout     => 0,
        }

        #
        # Set GIT URL to SSH-based URL if GIT_USER is set, or HTTPS for anonymous
        #
        if ( $user and $user != 'anonymous' ) {
            $url2 = "ssh://\"${user}\"@gerrit.wikimedia.org:29418/${title}.git"
        } else {
            $url2 = "https://gerrit.wikimedia.org/r/${title}.git"
        }
        exec { "git set-remote ${url2}":
            command     => "git remote set-url ${origin} ${url2}",
            onlyif      => "test $(git config --get remote.${origin}.url) != '${url2}'",
            cwd         => $directory,
            require     => Package['git'],
            user        => $owner,
            group       => $group,
            environment => 'HOME=/home/vagrant',
            timeout     => 0,
        }
    }
}
