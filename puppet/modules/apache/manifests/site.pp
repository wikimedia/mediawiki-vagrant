# Apache site resource type.
define apache::site(
	$site    = $title,
	$ensure  = 'present',
	$content = undef
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
	}
}
