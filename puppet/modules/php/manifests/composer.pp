# == Class: php::composer
#
# Provision and update Composer PHP dependency manager.
#
# === Parameters
#
# [*home*]
#   Composer home directory (COMPOSER_HOME). Default '/vagrant/cache/composer'
#
# [*cache_dir*]
#   Composer cache directory (COMPOSER_CACHE_DIR).
#   Default '/vagrant/cache/composer'
#
class php::composer (
    $home        = '/vagrant/cache/composer',
    $cache_dir   = '/vagrant/cache/composer',
) {
    exec { 'download_composer':
        command => 'curl https://getcomposer.org/composer.phar -o /usr/local/bin/composer',
        creates => '/usr/local/bin/composer',
    }

    file { '/usr/local/bin/composer':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Exec['download_composer'],
    }

    exec { 'update_composer':
        command     => 'composer self-update',
        environment => [
          "COMPOSER_HOME=${home}",
          "COMPOSER_CACHE_DIR=${cache_dir}",
          'COMPOSER_NO_INTERACTION=1',
        ],
        require     => [
            File['/usr/local/bin/composer'],
            Package['php5'],
        ],
        schedule    => 'weekly',
    }

    env::var { 'COMPOSER_CACHE_DIR':
        value => $cache_dir,
    }
}
