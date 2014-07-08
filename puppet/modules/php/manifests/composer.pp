# == Class: php::composer
#
# Provision and update Composer PHP dependency manager.
#
class php::composer {

    exec { 'download composer':
        command => 'curl -o composer https://getcomposer.org/composer.phar',
        cwd     => '/usr/bin',
        user    => 'root',
        creates => '/usr/bin/composer',
    }

    exec { 'fix composer permissions':
        command => 'chmod a+x /usr/bin/composer',
        user    => 'root',
        unless  => 'test -x /usr/bin/composer',
        require => Exec['download composer'],
    }

    exec { 'update composer':
        command     => '/usr/bin/composer self-update',
        environment => [ 'COMPOSER_HOME=/usr/bin' ],
        user        => 'root',
        onlyif      => 'test -n "`find /usr/bin/composer -mtime 14`"',
        require     => Exec['fix composer permissions'],
    }
}
