# == Class: misc
#
# Provides various small enhancements to user experience: a color
# prompt, a helpful MOTD banner, bash aliases, and some commonly-used
# command-line tools, like 'ack' and 'curl'.
#
class misc {
	include misc::virtualbox

	file { '/etc/profile.d/color.sh':
		ensure => file,
		mode   => '0755',
		source => 'puppet:///modules/misc/color.sh',
	}

	file { [
		'/etc/update-motd.d/10-help-text',
		'/etc/update-motd.d/50-landscape-sysinfo',
		'/etc/update-motd.d/51-cloudguest'
	]:
		ensure => absent,
	}

	# Look, I didn't pick the name..
	package { [ 'toilet', 'toilet-fonts' ]:
		ensure => present,
		before => File['/etc/update-motd.d/60-mediawiki-vagrant'],
	}

	file { '/etc/update-motd.d/60-mediawiki-vagrant':
		ensure  => present,
		mode    => '0755',
		source  => 'puppet:///modules/misc/60-mediawiki-vagrant',
		notify  => Exec['update motd'],
	}

	exec { 'update motd':
		command     => 'run-parts --lsbsysinit /etc/update-motd.d > /run/motd',
		refreshonly => true,
	}

	# Small, nifty, useful things
	package { [ 'ack-grep', 'htop', 'curl', 'tree' ]:
		ensure => present,
	}

	file { '/home/vagrant/.bash_aliases':
		ensure => present,
		mode   => '0755',
		source => 'puppet:///modules/misc/bash_aliases',
	}
}
