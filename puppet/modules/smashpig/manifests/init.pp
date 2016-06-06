# == Class: smashpig
#
# Provision a site to listen for realtime payment notifications.
#
class smashpig(
    $vhost_name,
    $dir,
) {
    include ::php
    include ::apache
    include ::git

    git::clone { 'wikimedia/fundraising/SmashPig':
        directory => $dir,
    }

    service::gitupdate { 'smashpig':
        dir    => $dir,
        type   => 'php',
        update => true,
    }

    file { '/etc/fundraising/SmashPig.yaml':
        content => template('smashpig/SmashPig.yaml.erb'),
        require => [
            Git::Clone['wikimedia/fundraising/SmashPig'],
        ],
    }

    file { "${dir}/PublicHttp/.htaccess":
        source  => "${dir}/PublicHttp/.htaccess.sample",
        require => Git::Clone['wikimedia/fundraising/SmashPig'],
    }

    php::composer::install { $dir:
        prefer  => 'source',
        require => Git::Clone['wikimedia/fundraising/SmashPig'],
    }

    apache::site { 'payments-listener':
        ensure  => present,
        content => template('smashpig/apache-site.erb'),
        require => [
            File['/etc/fundraising/SmashPig.yaml'],
            File["${dir}/PublicHttp/.htaccess"],
            Class['::apache::mod::rewrite'],
        ],
    }
}
