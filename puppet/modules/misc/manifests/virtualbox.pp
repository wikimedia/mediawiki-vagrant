# Declare host's VirtualBox version in /etc/virtualbox-version and provide a
# shell script for updating VirtualBox guest additions.
class misc::virtualbox {

	# Upon starting an interactive shell, check guest additions version and
	# prompt the user to update if out-of-date.
	file { '/etc/profile.d/check-guest-additions.sh':
		ensure => file,
		mode   => '0755',
		source => 'puppet:///modules/misc/check-guest-additions.sh',
	}

	# Shell script for updating guest additions.
	file { '/bin/update-guest-additions':
		ensure => present,
		source => 'puppet:///modules/misc/update-guest-additions',
		owner  => 'root',
		group  => 'root',
		mode   => '0755',
	}

	if ( $::virtualbox_version =~ /[\d.]+/ ) {
		file { '/etc/virtualbox-version':
			ensure  => present,
			content => inline_template("<%= scope.lookupvar('::virtualbox_version') %>\n"),
			owner   => 'root',
			group   => 'root',
			mode    => '0444',
		}
	}

	# Prerequisites for building new versions of guest additions.
	package { [ 'build-essential', "linux-headers-${::kernelrelease}" ]:
		ensure => present,
	}

}
