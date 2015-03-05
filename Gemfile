source 'https://rubygems.org'

group :development do
  gem 'vagrant', git: 'https://github.com/mitchellh/vagrant.git', tag: 'v1.7.2'
  gem 'rubocop', require: false
end

group :development, :test do
  gem 'fakefs', '~> 0.6.5'
  gem 'pry-byebug'
end

group :plugins do
  gemspec
end
