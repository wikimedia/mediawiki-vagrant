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
    $bin = '/usr/local/bin/composer'

    exec { 'download_composer':
        # composer-2.phar is "Latest 2.x"
        command => "curl https://getcomposer.org/composer-2.phar -o ${bin}",
        unless  => "php -r 'try { Phar::loadPhar(\"${bin}\"); exit(0); } catch(Exception \$e) { exit(1); }'",
        require => [
            Package['curl'],
            Class['php::package'],
        ],
    }

    file { '/usr/local/bin/composer':
        ensure  => file,
        owner   => 'root',
        group   => 'staff',
        mode    => '0755',
        require => Exec['download_composer'],
    }

    exec { 'update_composer':
        command     => '/usr/local/bin/composer self-update --2',
        environment => [
          "COMPOSER_HOME=${home}",
          "COMPOSER_CACHE_DIR=${cache_dir}",
          'COMPOSER_NO_INTERACTION=1',
        ],
        require     => [
            File['/usr/local/bin/composer'],
            Class['php::package'],
        ],
        schedule    => 'weekly',
    }

    env::var { 'COMPOSER_CACHE_DIR':
        value => $cache_dir,
    }

    env::profile_script { 'add composer global bin to path':
        content => 'export PATH=$PATH:~/.composer/vendor/bin',
    }
}
