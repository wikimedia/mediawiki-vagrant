# Apache site resource type.
define apache::site( $site = $title, $ensure = 'present', $content = undef ) {

	include apache

	case $ensure {
		present: {
			if ( $content ) {
				file { "/etc/apache2/sites-available/${site}":
					ensure  => file,
					content => $content,
					require => Package['apache2'],
					before  => Exec["/usr/sbin/a2ensite -qf ${site}"],
				}
			}
			exec { "/usr/sbin/a2ensite -qf ${site}":
				require => Package['apache2'],
				notify  => Exec['reload-apache2'],
				unless  => "a2dissite <<<'' | head -1 | cut -c 19- | grep -w ${site}"
			}
		}
		absent: {
			exec { "/usr/sbin/a2dissite -qf ${site}":
				require => Package['apache2'],
				notify  => Exec['reload-apache2'],
				onlyif  => "a2dissite <<<'' | head -1 | cut -c 19- | grep -w ${site}"
			}
		}
	}
}
