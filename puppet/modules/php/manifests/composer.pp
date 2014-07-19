# == Class: php::composer
#
# Provision and update Composer PHP dependency manager.
#
class php::composer {
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
        environment => 'COMPOSER_HOME=/usr/local/bin',
        require     => File['/usr/local/bin/composer'],
        onlyif      => 'test -n "$(find /usr/local/bin/composer -mtime 14)"',
    }

    env::var { 'COMPOSER_CACHE_DIR':
        value => '/vagrant/cache/composer',
    }
}
