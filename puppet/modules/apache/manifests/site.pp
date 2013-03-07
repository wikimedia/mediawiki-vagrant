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
				returns => [0, 1],
				require => Package['apache2'],
				notify  => Exec['reload-apache2'],
			}
		}
		absent: {
			exec { "/usr/sbin/a2dissite -qf ${site}":
				returns => [0, 1],
				require => Package['apache2'],
				notify  => Exec['reload-apache2'],
			}
		}
	}
}
