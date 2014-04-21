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

    $url = $remote ? {
        undef   => sprintf($git::urlformat, $title),
        default => $remote,
    }

    $origin = $user ? {
        ''      => 'origin',
        default => 'gerrit',
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
    # Make sure the remote is called "origin" for non-authenticated git, and "gerrit" when GIT_USER is set in Vagrantfile
    #
    $badorigin = $user ? {
        ''      => 'gerrit',
        default => 'origin',
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
    # Change GIT URL to the SSH-based URL if $user is set
    #
    if ( !$remote ) {
        $url2 =  "ssh://${user}@gerrit.wikimedia.org:29418/${title}.git"
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
