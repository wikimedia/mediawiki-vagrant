# vim:set sw=4 ts=4 sts=4 et:

# == Class: phabricator
#
# This class provisions an Apache vhost running the Phabricator application,
# creates the application database.
#
# === Parameters
#
# [*deploy_dir*]
#   Directory to clone Phabricator git repo in.
#
# [*log_dir*]
#   Directory phd will write logs to.
#
# [*vhost_name*]
#   Phabricator vhost name.
#
# [*remote*]
#   Phabricator git remote.
#
# [*dbuser*]
#   Database user
#
# [*dbpass*]
#   Database password
#
# [*branch*]
#   Phabricator branch to check out. If left undefined the default HEAD of the
#   remote will be used.
#
class phabricator(
    $deploy_dir,
    $log_dir,
    $vhost_name,
    $remote,
    $dbuser,
    $dbpass,
    $branch = undef,
    $protocol = 'http',
){
    require ::arcanist
    include ::apache
    include ::apache::mod::rewrite
    include ::mysql
    include ::php

    require_package(
        'python-pygments',
        'python-phabricator',
        'php-mailparse',
        'php-ldap'
    )

    php::ini { 'phab_post_max_size':
        settings => [
            'post_max_size = 32M'
        ],
    }

    git::clone { 'phabricator':
        directory => "${deploy_dir}/phabricator",
        remote    => $remote,
        branch    => $branch,
    }

    service::gitupdate { 'phd':
        dir => "${deploy_dir}/phabricator",
    }

    # Add our vhost
    apache::site { $vhost_name:
        ensure   => present,
        # Load before MediaWiki vhost for Labs where the MediaWiki wildcard
        # vhost is likely to conflict with our hostname.
        priority => 40,
        content  => template('phabricator/apache.conf.erb'),
        require  => Class['::apache::mod::rewrite'],
    }

    mysql::user { $dbuser:
        password => $dbpass,
        grant    => 'ALL ON \`phabricator\_%\`.*',
    }

    phabricator::config { 'mysql.host':
        value => '127.0.0.1',
    }

    phabricator::config { 'mysql.port':
        value => 3306,
    }

    phabricator::config { 'mysql.user':
        value => $dbuser,
    }

    phabricator::config { 'mysql.pass':
        value => $dbpass,
    }

    phabricator::config { 'phabricator.base-uri':
        value => "${protocol}://${vhost_name}${::port_fragment}/",
    }

    phabricator::config { 'pygments.enabled':
        value => true,
    }

    phabricator::config { 'metamta.mail-adapter':
        value => 'PhabricatorMailImplementationTestAdapter',
    }

    phabricator::config { 'phabricator.developer-mode':
        value => true,
    }

    phabricator::config { 'storage.mysql-engine.max-size':
        value => 0,
    }

    group { 'phd':
        ensure => present,
        system => true,
    }
    user { 'phd':
        gid        => 'phd',
        shell      => '/bin/false',
        managehome => false,
        system     => true,
    }
    file { '/home/phd':
        ensure  => 'directory',
        owner   => 'phd',
        group   => 'phd',
        mode    => '0755',
        require => [
            User['phd'],
            Group['phd'],
        ],
    }
    phabricator::config { 'phd.user':
        value   => 'phd',
        require => [
            User['phd'],
            File['/home/phd'],
        ],
    }

    # Repository hosting
    file { '/var/repo':
        ensure => directory,
        mode   => '0755',
        owner  => 'phd',
        group  => 'www-data',
    }

    phabricator::config { 'repository.default-local-path':
        value   => '/var/repo',
        require => File['/var/repo'],
    }

    file { '/usr/local/bin/git-http-backend':
        ensure  => 'link',
        target  => '/usr/lib/git-core/git-http-backend',
        require => Package['git'],
    }

    sudo::user { 'www-data as phd':
        user       => 'www-data',
        privileges => [
            'ALL=(phd) SETENV: NOPASSWD: /usr/bin/git, /usr/local/bin/git-http-backend',
        ],
        require    => File['/usr/local/bin/git-http-backend'],
    }

    phabricator::config { 'diffusion.allow-http-auth':
        value => true,
    }
    phabricator::config { 'security.require-https':
        value => false,
    }

    # File uploads
    file { '/srv/phabfiles':
        ensure => directory,
        owner  => 'www-data',
    }

    phabricator::config { 'storage.local-disk.path':
        value   => '/srv/phabfiles',
        require => File['/srv/phabfiles'],
    }

    # Setup databases
    exec { 'phab_setup_db':
        command => "${deploy_dir}/phabricator/bin/storage upgrade --force",
        require => [
            Class['::mysql'],
            Phabricator::Config['mysql.host'],
            Phabricator::Config['mysql.user'],
            Phabricator::Config['mysql.pass'],
            Phabricator::Config['mysql.port'],
            Mysql::User[$dbuser],
        ],
        unless  => "${deploy_dir}/phabricator/bin/storage status > /dev/null",
    }

    file { '/var/run/phd':
        ensure => 'directory',
        owner  => 'phd',
        group  => 'phd',
        mode   => '0775',
    }
    phabricator::config { 'phd.pid-directory':
        value   => '/var/run/phd',
        require => File['/var/run/phd'],
    }
    file { $log_dir:
        ensure => 'directory',
        mode   => '0777',
    }
    phabricator::config { 'phd.log-directory':
        value   => $log_dir,
        require => File[$log_dir],
    }

    $phd = "${deploy_dir}/phabricator/bin/phd"
    service { 'phd':
        ensure   => running,
        enable   => true,
        provider => base,
        binary   => $phd,
        start    => "${phd} start",
        stop     => "${phd} stop",
        status   => "${phd} status | grep -v DEAD",
        require  => Exec['phab_setup_db'],
    }
}
