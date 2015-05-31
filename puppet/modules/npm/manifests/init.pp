# == Class: npm
#
# Provision npm dependency manager.
#
# === Parameters
#
# [*cache_dir*]
#   Npm cache directory (npm_config_cache).
#   Default '/vagrant/cache/npm'
#
class npm (
    $cache_dir   = '/vagrant/cache/npm',
) {
    require_package('nodejs', 'npm', 'nodejs-legacy')

    env::var { 'NPM_CONFIG_CACHE':
        value => $cache_dir,
    }
}

