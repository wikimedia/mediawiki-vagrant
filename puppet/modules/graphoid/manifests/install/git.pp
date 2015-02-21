# == Class: graphoid::install::git
#
# Provision graphoid by cloning the git repository.
#
class graphoid::install::git {
    include ::graphoid

    git::clone{ 'mediawiki/services/graphoid':
        directory => $::graphoid::base_path,
        before    => Class['::graphoid'],
    }
}
