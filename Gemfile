source 'https://rubygems.org'

group :development do
  # Upstream no more updates rubygems.org and we need a more recent version
  # https://github.com/mitchellh/vagrant/issues/5546
  gem 'vagrant', git: 'https://github.com/mitchellh/vagrant.git', tag: 'v1.8.1'

  gem 'rubocop', '~> 0.35.1', require: false
  gem 'puppet-lint', '1.1.0'
  gem 'puppet', '~> 3.7.0'
  gem 'puppetlabs_spec_helper', '< 2.0.0', require: false
  gem 'puppet-strings', '~> 1.0.0'
  # Puppet 3.7 fails on ruby 2.2+
  # https://tickets.puppetlabs.com/browse/PUP-3796
  gem 'safe_yaml', '~> 1.0.4'
  gem 'rake', '~> 10.4.2'
end

group :development, :test do
  gem 'fakefs', '~> 0.6.5'
  gem 'pry-byebug'
end

group :plugins do
  gemspec
end
