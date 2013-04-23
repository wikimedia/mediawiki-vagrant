# Resource type for Apache modules.
define apache::mod(
	$mod    = $title,
	$ensure = present
) {
	include apache

	case $ensure {
		present: {
			exec { "/usr/sbin/a2enmod ${mod}":
				unless  => "test -f /etc/apache2/mods-enabled/${mod}.load",
				require => Package['apache2'],
				notify  => Service['apache2'],
			}
		}
		absent: {
			exec { "/usr/sbin/a2dismod ${mod}":
				onlyif  => "test -f /etc/apache2/mods-enabled/${mod}.load",
				require => Package['apache2'],
				notify  => Service['apache2'],
			}
		}
	}
}
