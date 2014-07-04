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
    $remote = $::git::urlformat,
    $owner  = 'vagrant',
    $group  = 'vagrant',
) {
    include ::git

    $url = sprintf($git::urlformat, $title)

    exec { "git_clone_${title}":
        command     => "/usr/bin/git clone --recursive --branch ${branch} ${url} ${directory}",
        creates     => "${directory}/.git",
        user        => $owner,
        group       => $group,
        require     => Package['git'],
        environment => 'HOME=/home/vagrant',
        timeout     => 0,
    }
}
