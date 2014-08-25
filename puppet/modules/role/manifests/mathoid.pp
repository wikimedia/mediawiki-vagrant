class role::mathoid {

    class { '::mathoid':
        base_path => '/srv/mathoid',
        node_path => '/srv/mathoid/node_modules',
        conf_path => '/srv/mathoid/mathoid.config.json',
        log_dir   => '/vagrant/log/mathoid',
        require   => Git::Clone['mediawiki/services/mathoid'],
    }
}