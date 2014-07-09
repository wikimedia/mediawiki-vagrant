# == Class: mediawiki::apache
#
# This class configures the Apache HTTP server to serve MediaWiki.
#
class mediawiki::apache {
    include ::mediawiki

    include ::apache
    include ::apache::mod::alias
    include ::apache::mod::rewrite
    include ::apache::mod::proxy_fcgi

    apache::site { 'default':
        ensure => absent,
    }

    apache::site { $mediawiki::wiki_name:
        ensure  => present,
        content => template('mediawiki/mediawiki-apache-site.erb'),
        require => Class['::apache::mod::alias', '::apache::mod::rewrite', '::apache::mod::proxy_fcgi'],
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
