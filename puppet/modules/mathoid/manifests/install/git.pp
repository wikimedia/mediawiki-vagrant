# == Class: mathoid::install::git
#
# Provision mathoid by cloning the git repository.
#
class mathoid::install::git {
    include ::mathoid

    git::clone{ 'mediawiki/services/mathoid':
        directory => $::mathoid::base_path,
        before    => Class['::mathoid'],
    }
}
