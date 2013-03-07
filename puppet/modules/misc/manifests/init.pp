# Provides small enhancements to the shell, such as color prompt and MOTD.
class misc {

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

	package { ['toilet', 'toilet-fonts']:
		ensure => present,
		before => File['/etc/update-motd.d/60-mediawiki-vagrant'],
	}

	file { '/etc/update-motd.d/60-mediawiki-vagrant':
		ensure => present,
		mode   => '0755',
		source => 'puppet:///modules/misc/60-mediawiki-vagrant',
		notify => Exec['update-motd'],
	}

	exec { 'update-motd':
		command     => 'run-parts --lsbsysinit /etc/update-motd.d > /run/motd',
		refreshonly => true,
	}

}
