# Rakefile
# --------
# Run 'rake lint' to lint Puppet files. Requires 'puppet-lint'.
#
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_2sp_soft_tabs')
PuppetLint.configuration.send('disable_class_parameter_defaults')

PuppetLint.configuration.ignore_paths = [
    'puppet/manifests/roles.pp',
    'puppet/manifests/packages.pp',
    'puppet/modules/apache/manifests/mods.pp',
]

task :default => [:lint]
