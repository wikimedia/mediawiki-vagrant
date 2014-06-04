# puppet-rbenv

[![Build Status](https://travis-ci.org/justindowning/puppet-rbenv.png)](https://travis-ci.org/justindowning/puppet-rbenv)

## Description
This Puppet module will install and manage [rbenv](http://rbenv.org). By default, it installs
rbenv for systemwide use, rather than for a user or project. Additionally,
you can install different versions of Ruby, rbenv plugins, and Ruby gems.

## Installation

`puppet module install --modulepath /path/to/puppet/modules jdowning-rbenv`

## Usage
To use this module, you must declare it in your manifest like so:

    class { 'rbenv': }

If you wish to install rbenv somewhere other than the default
(`/usr/local/rbenv`), you can do so by declaring the `install_dir`:

    class { 'rbenv': install_dir => '/opt/rbenv' }

The class will merely setup rbenv on your host. If you wish to install
rubies, plugins, or gems, you will have to add those declarations to your manifests
as well.

### Installing Ruby using ruby-build
Ruby requires additional packages to operate properly. Fortunately, this module
will ensure these dependencies are met before installing Ruby. To install Ruby
you will need the [ruby-build](https://github.com/sstephenson/ruby-build) plugin from @sstephenson. Once
installed, you can install most any Ruby. Additionally, you can set the Ruby
to be the global interpreter.

    rbenv::plugin { 'sstephenson/ruby-build': }
    rbenv::build { '2.0.0-p247': global => true }

## Plugins
Plugins can be installed from GitHub using the following definiton:

    rbenv::plugin { 'github_user/github_repo': }

## Gems
Gems can be installed too! You *must* specify the `ruby_version` you want to
install for.

    rbenv::gem { 'thor': ruby_version => '2.0.0-p247' }

## Full Example
site.pp

    class { 'rbenv': }
    rbenv::plugin { [ 'sstephenson/rbenv-vars', 'sstephenson/ruby-build' ]: }
    rbenv::build { '2.0.0-p247': global => true }
    rbenv::gem { 'thor': ruby_version   => '2.0.0-p247' }

## Testing
You can test this module with rspec:

    bundle install
    bundle exec rake spec

## Vagrant

You can also test this module in a Vagrant box. There are two box definitons included in the
Vagrant file for CentOS, Debian, and Ubuntu testing. You will need to use `librarian-puppet` to setup
dependencies:

    bundle install
    bundle exec librarian-puppet install

To test both boxes:

    vagrant up

To test one distribution:

    vagrant up [centos|debian|ubuntu]
