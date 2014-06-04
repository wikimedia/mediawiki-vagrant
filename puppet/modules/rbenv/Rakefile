require 'puppet-lint/tasks/puppet-lint'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'

PuppetLint.configuration.send("disable_80chars")
PuppetLint.configuration.ignore_paths = ["pkg/**/**/*.pp","modules/**/**/*.pp"]
