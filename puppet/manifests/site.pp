# == Mediawiki-Vagrant Puppet Manifest
#
# This manifest is the main entrypoint for Puppet, the configuration
# management tool that sets up this machine to run MediaWiki. The
# manifest specifies which classes of services should be enabled on this
# virtual machine.
#
import 'base.pp'
import 'packages.pp'
import 'roles/*.pp'
import 'manifests.d/*.pp'

node default {
    include role::mediawiki
}
