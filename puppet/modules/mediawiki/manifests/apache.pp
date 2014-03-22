# == Class: mediawiki::apache
#
# This class configures the Apache HTTP server to serve MediaWiki.
#
class mediawiki::apache {
    include ::mediawiki
    include ::apache
    include ::apache::mods::alias
    include ::apache::mods::rewrite

    apache::site { 'default':
        ensure => absent,
    }

    apache::site { $mediawiki::wiki_name:
        ensure  => present,
        content => template('mediawiki/mediawiki-apache-site.erb'),
        require => Apache::Mod['alias', 'rewrite'],
        listen  => [ '_default_:80', '_default_:8080' ],
    }

    file { '/var/www/favicon.ico':
        ensure  => file,
        require => Package['apache2'],
        source  => 'puppet:///modules/mediawiki/favicon.ico',
    }

    file { '/var/www/info.php':
        ensure  => file,
        require => Package['apache2'],
        source  => 'puppet:///modules/mediawiki/info.php',
    }
}
