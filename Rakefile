# Rakefile
# --------
#
# You must use 'bundler install' first
#

# pre-flight
require 'bundler/setup'

# tasks dependencies
require 'cucumber'
require 'cucumber/rake/task'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'
require 'puppet-strings/tasks/generate'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

# Work around bug in puppet-lint configuration
# https://github.com/rodjek/puppet-lint/issues/331
Rake::Task[:lint].clear
PuppetLint::RakeTask.new(:lint) do |config|
  gitmodules = File.expand_path('../.gitmodules', __FILE__)
  config.ignore_paths = IO.readlines(gitmodules).grep(/\s*path\s*=\s*(\S+)/) {
    "#{Regexp.last_match(1)}/**/*.pp"
  }
  config.ignore_paths += ['tmp/**/*.pp']
  config.log_format = '%{path}:%{linenumber} %{KIND}: %{message}'
end
Cucumber::Rake::Task.new(:cucumber)
RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

task default: [:test]

desc 'Run all build/tests commands (CI entry point)'
task test: [:syntax, :spec, :rubocop, :cucumber, :lint, :doc]

desc 'Generate all documentations'
task :doc do
  # rubocop defines a :Parser constant which later confused Puppet 3.7 PSON
  # module which attempts to remove the undefined constant PSON:Parser because
  # :Parser is set -- hashar
  Object.send(:remove_const, :Parser) if defined? Parser
  Rake::Task['strings:generate'].invoke(
    '**/*.pp **/*.rb',  # patterns
    'false', # debug
    'false', # backtrace
    'rdoc',  # markup format
  )
end
