# == Class: mediawiki::apache
#
# This class configures the Apache HTTP server to serve MediaWiki.
#
# === Parameters
#
# [*docroot*]
#   Document root for Apache vhost serving MediaWiki.
#
class mediawiki::apache(
    $docroot,
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

    apache::site { "php5-${mediawiki::wiki_name}":
        ensure  => present,
        content => template('mediawiki/mediawiki-php5-site.erb'),
        require => Class['::apache::mod::alias', '::apache::mod::rewrite'],
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
