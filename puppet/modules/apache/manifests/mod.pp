# Resource type for Apache modules.
define apache::mod(
	$mod    = $title,
	$ensure = present
) {
	include apache

	case $ensure {
		present: {
			exec { "a2enmod ${mod}":
				unless  => "apache2ctl -M | grep -q ${mod}",
				require => Package['apache2'],
				notify  => Service['apache2'],
			}
		}
		absent: {
			exec { "a2dismod ${mod}":
				onlyif  => "apache2ctl -M | grep -q ${mod}",
				require => Package['apache2'],
				notify  => Service['apache2'],
			}
		}
	}
}
