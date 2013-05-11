# == Base Puppet manifest
#
# This manifest declares resource defaults for the Mediawiki-Vagrant
# Puppet site. All Puppet modules bundled with this project have an
# implicit dependency on this manifest and the declarations it contains.
# Modify this file with care.
#
# For more information about resource defaults in Puppet, see
# <http://docs.puppetlabs.com/puppet/2.7/reference/lang_defaults.html>.
#

# Declares a default search path for executables, allowing the path to
# be omitted from individual resources. Also configures Puppet to log
# the command's output if it was unsuccessful.
Exec {
	path      => [ '/bin', '/usr/bin', '/usr/sbin/', '/usr/local/bin' ],
	logoutput => on_failure,
}

# Ensure that apt-get update has ran in the last 24 hours before
# installing any packages.
Package {
	require => Exec['update package index'],
}

# Declare default uid / gid and permissions for file resources, and
# tells Puppet not to back up configuration files by default.
File {
	backup => false,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',
}

# Emit a notice indicating whether or not the host's VirtualBox version
# was detected. See ../../Vagrantfile for the version detection code.
if ( $::virtualbox_version ) {
	notice("Detected VirtualBox version ${::virtualbox_version}")
} else {
	warning('Could not determine VirtualBox version.')
}

# Run 'apt-get update' if the package index has not been updated in the
# last 24 hours.
exec { 'update package index':
	command => 'apt-get update',
	unless  => 'bash -c \'(( $(date +%s) - $(stat -c %Y /var/lib/apt/periodic/update-success-stamp) < 86400 ))\''
}

# Configures a 'puppet' user group, required by Puppet.
group { 'puppet':
	ensure => present,
}
