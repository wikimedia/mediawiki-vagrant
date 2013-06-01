# == Mediawiki-Vagrant Puppet Manifest
#
# This manifest is the main entrypoint for Puppet, the configuration
# management tool that sets up this machine to run MediaWiki. The
# manifest specifies which classes of services should be enabled on this
# virtual machine.
#
# By default, the Mediawiki-Vagrant virtual machine is configured to run
# a plain MediaWiki instance, with some small enhancements designed to
# make it easy to hack on MediaWiki code. However, MediaWiki-Vagrant
# knows how to configure a machine to fulfill various other roles which
# are not enabled by default.
#
# To enable an optional role, simply uncomment its delcaration below by
# removing the leading '#' symbol and saving this file. Then, run
# 'vagrant up' to ensure your machine is active, and then 'vagrant
# provision' to apply the updated configuration to your instance.
#
#
import 'base.pp'
import 'roles.pp'

node 'mediawiki-vagrant' {
	include role::mediawiki

	# include role::scribunto
	# include role::uploadwizard
	# include role::visualeditor
	# include role::browsertests
	# include role::echo
	# include role::eventlogging
	# include role::gettingstarted
	# include role::mobilefrontend
	# include role::umapi
	# include role::remote_debug
}
