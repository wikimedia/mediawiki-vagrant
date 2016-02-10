# == Class: npm
#
# Provision npm dependency manager.
#
# === Parameters
#
# [*cache_dir*]
#   Npm cache directory (npm_config_cache).
#   Default '/tmp/cache/npm'
#
class npm (
    $cache_dir   = '/tmp/cache/npm',
) {

    include ::apt

    # set up the nodesource repo pubkey
    file { '/usr/local/share/nodesource-pubkey.asc':
        source => 'puppet:///modules/npm/nodesource-pubkey.asc',
        owner  => 'root',
        group  => 'root',
        before => File['/etc/apt/sources.list.d/nodesource.list'],
        notify => Exec['add_nodesource_apt_key'],
    }

    # add the key
    exec { 'add_nodesource_apt_key':
        command     => '/usr/bin/apt-key add /usr/local/share/nodesource-pubkey.asc',
        before      => File['/etc/apt/sources.list.d/nodesource.list'],
        refreshonly => true,
        require     => [
            Exec['ins-apt-transport-https'],
            Exec['ins-npm-nodejs-legacy'],
        ],
    }

    # add the nodesource repo list file
    file { '/etc/apt/sources.list.d/nodesource.list':
        source  => 'puppet:///modules/npm/nodesource.sources.list',
        owner   => 'root',
        group   => 'root',
        require => Exec['ins-apt-transport-https'],
        notify  => Exec['apt-get update'],
    }

    # install the npm and nodejs-legacy packages manually
    # before the nodesource repo has been added so as not to
    # conflict for package versions
    exec { 'ins-npm-nodejs-legacy':
        command     => '/usr/bin/apt-get update && /usr/bin/apt-get install -y --force-yes npm nodejs-legacy',
        environment => 'DEBIAN_FRONTEND=noninteractive',
        unless      => '/usr/bin/dpkg -l npm && /usr/bin/dpkg -l nodejs-legacy',
        user        => 'root',
    }

    package { 'nodejs':
        ensure  => latest,
        require => [
            File['/etc/apt/sources.list.d/nodesource.list'],
            Exec['apt-get update']
        ],
    }

    exec { 'npm_set_cache_dir':
        command => "/bin/mkdir -p ${cache_dir} && /bin/chmod -R 0777 ${cache_dir}",
        unless  => "/usr/bin/test -d ${cache_dir}",
        user    => 'root',
        group   => 'root',
    }

    env::var { 'NPM_CONFIG_CACHE':
        value   => $cache_dir,
        require => Exec['npm_set_cache_dir'],
    }
}

