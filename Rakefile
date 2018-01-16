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
require 'rake/clean'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'

# Tell `rake clean` to get rid of generated test files
CLEAN.include('tmp/testenv')

# Work around bug in puppet-lint configuration
# https://github.com/rodjek/puppet-lint/issues/331
Rake::Task[:lint].clear
PuppetLint::RakeTask.new(:lint) do |config|
  gitmodules = File.expand_path('../.gitmodules', __FILE__)
  config.ignore_paths = IO.readlines(gitmodules).grep(/\s*path\s*=\s*(\S+)/) {
    "#{Regexp.last_match(1)}/**/*.pp"
  }
  config.ignore_paths += ['puppet/modules/stdlib/**/*.pp']
  config.ignore_paths += ['tmp/**/*.pp']
  config.log_format = '%{path}:%{line} %{KIND}: %{message}'
end
Cucumber::Rake::Task.new(:cucumber) do |t|
  t.cucumber_opts = '-r tests/features tests/features'
end
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '-I tests/spec --default-path tests'
end

desc 'Compile default host Puppet catalog'
RSpec::Core::RakeTask.new(:compile_host) do |t|
  t.rspec_opts = '--format doc -I puppet/spec --default-path puppet --pattern spec/hosts/\*_spec.rb'
end
desc 'Compile Puppet roles'
RSpec::Core::RakeTask.new(:compile_roles) do |t|
  t.rspec_opts = '-I puppet/spec --default-path puppet --exclude-pattern spec/hosts/\*_spec.rb'
end
# Compile host first since it is fairly fast
desc 'Compile puppet catalogs'
task compile: [:compile_host, :compile_roles]

RuboCop::RakeTask.new(:rubocop)

task default: [:test]

desc 'Run all build/tests commands (CI entry point)'
task test: [:clean, :syntax, :spec, :rubocop, :cucumber, :lint, :doc, :compile_host]

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
