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

# By adding a stage => 'first' / 'last' parameter to your class
# declaration, you can tell Puppet to instantiate the class (and its
# resources) at the very beginning of its run or the very end. By
# default, only the 'apt' class runs in a different stage, to ensure
# other classes fetch the right packages. Everything else runs in 'main'.
# For more information, see:
# <http://docs.puppetlabs.com/puppet/2.7/reference/lang_run_stages.html>
stage { 'first': }
stage { 'last': }

Stage['first'] -> Stage['main'] -> Stage['last']

# Declares a default search path for executables, allowing the path to
# be omitted from individual resources. Also configures Puppet to log
# the command's output if it was unsuccessful.
Exec {
	logoutput => on_failure,
	path      => [ '/bin', '/usr/bin', '/usr/local/bin', '/usr/sbin/' ],
}

Package { ensure => present, }

# Declare default uid / gid and permissions for file resources, and
# tells Puppet not to back up configuration files by default.
File {
	backup => false,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',
}

package { 'python-pip':
	ensure => present,
}

Package['python-pip'] -> Package <| provider == pip |>
