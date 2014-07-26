# == Class: mediawiki::apache
#
# This class configures the Apache HTTP server to serve MediaWiki.
#
# === Parameters
#
# [*docroot*]
#   Document root for Apache vhost serving MediaWiki. Default is /var/www
#
class mediawiki::apache(
    $docroot = '/var/www',
) {
    include ::mediawiki
    include ::mediawiki::multiwiki

    include ::apache
    include ::apache::mod::alias
    include ::apache::mod::rewrite
    include ::apache::mod::proxy_fcgi
    include ::apache::mod::headers

    apache::site { 'default':
        ensure => absent,
    }

    apache::site { $mediawiki::wiki_name:
        ensure  => present,
        content => template('mediawiki/mediawiki-apache-site.erb'),
        require => Class['::apache::mod::alias', '::apache::mod::rewrite', '::apache::mod::proxy_fcgi'],
    }

    file { "${docroot}/favicon.ico":
        ensure  => file,
        require => Package['apache2'],
        source  => 'puppet:///modules/mediawiki/favicon.ico',
    }

    file { "${docroot}/info.php":
        ensure  => file,
        require => Package['apache2'],
        source  => 'puppet:///modules/mediawiki/info.php',
    }
}
