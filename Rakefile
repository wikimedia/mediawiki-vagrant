# Rakefile
# --------
# Run 'rake lint' to lint Puppet files. Requires 'puppet-lint'.
#
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.send('disable_autoloader_layout')

gitmodules = File.expand_path '../.gitmodules', __FILE__

PuppetLint.configuration.ignore_paths = [
    'puppet/modules/apache/manifests/mod.pp',
    'puppet/modules/hhvm/manifests/init.pp',
] + IO.readlines(gitmodules).grep(/\s*path\s*=\s*(\S+)/) { "#{$1}/**/*.pp" }

task :default => [:lint]
