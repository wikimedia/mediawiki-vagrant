# == Define: apache::site
#
# Manages Apache site configurations.
#
# === Parameters
#
# [*ensure*]
#   If 'present', site will be enabled; if 'absent', disabled. The
#   default is 'present'.
#
# [*site*]
#   Name of site. The resource title will be used if this is
#   unspecified.
#
# [*content*]
#   If defined, will be used as the content of the site configuration
#   file. Undefined by default.
#
# [*source*]
#   Path to file containing configuration directives. Undefined by
#   default.
#
# === Examples
#
#  apache::site { 'wiki':
#    ensure  => present,
#    content => template('mediawiki/mediawiki-apache-site.erb'),
#  }
#
define apache::site(
    $ensure  = 'present',
    $site    = $title,
    $content = undef,
    $source  = undef,
) {
    include apache

    if ( $site == 'default' ) {
        $site_file = '000-default'
    } else {
        $site_file = $site
    }

    case $ensure {
        present: {
            file { "/etc/apache2/site.d/${site}":
                ensure  => directory,
                recurse => true,
                purge   => true,
                force   => true,
                before  => File["/etc/apache2/sites-available/${site_file}"],
            }

            apache::conf { $site:
                ensure  => $ensure,
                site    => $site,
                content => $content,
                source  => $source,
            }

            file { "/etc/apache2/sites-available/${site_file}":
                ensure  => file,
                content => template('apache/site.conf.erb'),
                require => Package['apache2'],
                before  => Exec["enable ${site}"],
            }

            exec { "enable ${title}":
                command => "a2ensite -qf ${site}",
                unless  => "test -L /etc/apache2/sites-enabled/${site_file}",
                notify  => Service['apache2'],
                require => Package['apache2'],
            }
        }
        absent: {
            exec { "disable ${title}":
                command => "a2dissite -qf ${site}",
                onlyif  => "test -L /etc/apache2/sites-enabled/${site_file}",
                notify  => Service['apache2'],
                require => Package['apache2'],
            }
        }
        default: {
            fail("'ensure' may be 'present' or 'absent' (got: '${ensure}').")
        }
    }
}
