# Rakefile
# --------
# Run 'rake lint' to lint Puppet files. Requires 'puppet-lint'.
#
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_2sp_soft_tabs')
PuppetLint.configuration.send('disable_hard_tabs')
PuppetLint.configuration.ignore_paths = ['puppet/manifests/roles.pp']
