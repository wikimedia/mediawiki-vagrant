# == Class: smashpig
#
# Provision a site to listen for realtime payment notifications.
#
class smashpig(
    $vhost_name,
    $dir,
    $db_name,
    $db_pass,
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

    file { ['/etc/smashpig', '/etc/smashpig/adyen', '/etc/smashpig/paypal']:
        ensure => directory
    }

    file { '/etc/smashpig/main.yaml':
        content => template('smashpig/smashpig/main.yaml.erb'),
        require => [
            Git::Clone['wikimedia/fundraising/SmashPig'],
            File['/etc/smashpig'],
        ],
    }

    file { '/etc/smashpig/adyen/main.yaml':
        content => template('smashpig/smashpig/adyen/main.yaml.erb'),
        require => [
            Git::Clone['wikimedia/fundraising/SmashPig'],
            File['/etc/smashpig/adyen'],
        ],
    }

    file { '/etc/smashpig/paypal/main.yaml':
        content => template('smashpig/smashpig/paypal/main.yaml.erb'),
        require => [
            Git::Clone['wikimedia/fundraising/SmashPig'],
            File['/etc/smashpig/paypal'],
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
            File['/etc/smashpig/main.yaml'],
            File["${dir}/PublicHttp/.htaccess"],
            Class['::apache::mod::rewrite'],
        ],
    }

    mysql::user { $db_name :
      ensure   => present,
      grant    => 'ALL ON *.*',
      password => $db_pass,
      require  => Mysql::Db['smashpig'],
    }

    mysql::db { 'smashpig': }

    exec { 'smashpig_schema':
        command => "cat ${dir}/Schema/mysql/*.sql | /usr/bin/mysql smashpig -qfsA",
        require => [
            Git::Clone['wikimedia/fundraising/SmashPig'],
            Mysql::Db['smashpig'],
        ],
    }

    file { '/etc/cron.d/SmashPig':
        content => template('smashpig/SmashPig.cron.d.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0644'
    }

}
