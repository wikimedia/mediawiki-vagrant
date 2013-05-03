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
) {

	include apache

	case $ensure {
		present: {
			if ( $content ) {
				file { "/etc/apache2/sites-available/${site}":
					ensure  => file,
					content => $content,
					require => Package['apache2'],
					before  => Exec["enable ${site}"],
				}
			}
			exec { "enable ${title}":
				command => "a2ensite -qf ${site}",
				notify  => Service['apache2'],
				require => Package['apache2'],
				unless  => "a2dissite <<<'' | head -1 | cut -c 19- | grep -w ${site}",
			}
		}
		absent: {
			exec { "disable ${title}":
				command => "a2dissite -qf ${site}",
				notify  => Service['apache2'],
				require => Package['apache2'],
				onlyif  => "a2dissite <<<'' | head -1 | cut -c 19- | grep -w ${site}",
			}
		}
		default: {
			fail("'ensure' may be 'present' or 'absent' (got: '${ensure}').")
		}
	}
}
