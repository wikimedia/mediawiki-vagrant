source 'https://rubygems.org'

group :development do
  # The versions should be kept in sync with the ones provided in Debian

  # Upstream no more updates rubygems.org and we need a more recent version
  # https://github.com/hashicorp/vagrant/issues/5546
  gem 'vagrant', git: 'https://github.com/hashicorp/vagrant.git', tag: 'v1.9.1'
  gem 'rubocop', '~> 0.51', require: false
  gem 'puppet', '~> 5.5.22'
  gem 'puppet-lint', '2.3.3'
  gem 'puppetlabs_spec_helper', '< 2.0.0', require: false
  gem 'rspec-puppet', '~> 2.6.5', require: false
  gem 'puppet-strings', '~> 1.0.0'
  gem 'safe_yaml', '~> 1.0.4'
  gem 'rake', '~> 12.0.0'
end

group :development, :test do
  gem 'fakefs', '~> 0.6.5'
  gem 'byebug', '~> 9.0.6'
  gem 'pry-byebug'
end

group :plugins do
  gemspec
end
