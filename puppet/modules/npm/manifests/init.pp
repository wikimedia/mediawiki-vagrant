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
    $cache_dir   = '/tmp/cache/npm'
) {
    require_package('npm')

    exec { 'npm_set_cache_dir':
        command => "/bin/mkdir -p ${cache_dir} && /bin/chmod -R 0777 ${cache_dir} && /bin/chown -R 1000:1000 ${cache_dir}",
        unless  => "/usr/bin/test -d ${cache_dir}",
        user    => 'root',
        group   => 'root',
    }

    env::var { 'NPM_CONFIG_CACHE':
        value   => $cache_dir,
        require => Exec['npm_set_cache_dir'],
    }
}
