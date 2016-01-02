# == Mediawiki-Vagrant Puppet Manifest
#
# This manifest is the main entrypoint for Puppet, the configuration
# management tool that sets up this machine to run MediaWiki. The
# manifest specifies which classes of services should be enabled on this
# virtual machine.

# For more information about resource defaults in Puppet, see
# <http://docs.puppetlabs.com/puppet/2.7/reference/lang_defaults.html>.

# By adding a stage => 'first' / 'last' parameter to your class
# declaration, you can tell Puppet to instantiate the class (and its
# resources) at the very beginning of its run or the very end. See:
# <http://docs.puppetlabs.com/puppet/2.7/reference/lang_run_stages.html>
stage { 'first': } -> Stage['main'] -> stage { 'last': }

# Human-readable constants which may be used in lieu of literal numbers
# for specifying loading priority of resource types which support this
# notion (like mediawiki::extension, mediawiki::settings, and mediawiki::wiki).
$LOAD_FIRST  = 0
$LOAD_EARLY  = 5
$LOAD_NORMAL = 10
$LOAD_LATER  = 15
$LOAD_LAST   = 20

# Declares a default search path for executables, allowing the path to
# be omitted from individual resources. Also configures Puppet to log
# the command's output if it was unsuccessful. Finally, set timeout to
# 900 seconds, which is three times Puppet's default.
Exec {
    logoutput => on_failure,
    timeout   => 900,
    path      => [ '/bin', '/sbin', '/usr/bin', '/usr/local/bin', '/usr/sbin' ],
}

Service {
    ensure => running,
    enable => true,
}

Package {
    ensure => present,
}

# Tell Puppet not to back up configuration files by default.
File {
    backup => false,
}

# Assign classes to nodes via hiera
# See hiera.yaml and hieradata/*.yaml
hiera_include('classes')
