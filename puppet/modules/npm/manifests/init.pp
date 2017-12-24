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

    apt::repository { 'nodesource':
        uri        => 'https://deb.nodesource.com/node_6.x',
        dist       => $::lsbdistcodename,
        components => 'main',
        keyfile    => 'puppet:///modules/npm/nodesource-pubkey.asc',
    }

    # Pin it higher than the Wikimedia repo
    apt::pin { 'nodejs':
        package  => 'nodejs',
        pin      => 'release o=Node Source',
        priority => 1010,
    }

    package { 'nodejs':
        ensure  => latest,
        require => [
            Apt::Repository['nodesource'],
            Apt::Pin['nodejs'],
        ],
    }

    exec { 'npm_set_cache_dir':
        command => "/bin/mkdir -p ${cache_dir} && /bin/chmod -R 0777 ${cache_dir}",
        unless  => "/usr/bin/test -d ${cache_dir}",
        user    => 'root',
        group   => 'root',
    }

    # Node 6 brings in npm 3 that doesn't work in shared folders due to a bug.
    # See: https://github.com/npm/npm/issues/9953
    # Although the ticket is closed, the issue is still present, so downgrade
    # to the latest npm 2
    exec { 'downgrade_npm':
      command => '/usr/bin/npm install -g npm@latest-2',
      user    => 'root',
      unless  => '/usr/bin/npm --version | /bin/grep -qe ^2',
      require => Package['nodejs'],
    }

    env::var { 'NPM_CONFIG_CACHE':
        value   => $cache_dir,
        require => Exec['npm_set_cache_dir'],
    }
}

