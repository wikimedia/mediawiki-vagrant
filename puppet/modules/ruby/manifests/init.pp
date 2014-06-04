# == Class: ruby
#
# Provides isolated versions of Ruby and gems and resources for declaring
# which versions should be used in certain contexts.
#
# === Examples
#
# Install the default version of Ruby and Nokogiri.
#
#   include ruby::default
#   ruby::gem { 'nokogiri': }
#
# Install Ruby 2.2.0-dev and Nokogiri. (Note that you must specify a ruby
# version when not using the default.)
#
#   ruby::ruby { '2.2.0-dev': }
#   ruby::gem { 'nokogiri': ruby => '2.2.0-dev' }
#
# Install Ruby 2.2.0-dev and any version of Nokogiri before 1.6.
#
#   ruby::ruby { '2.2.0-dev': }
#   ruby::gem { 'nokogiri': ruby => '2.2.0-dev', version => '<1.6' }
#
# Install the default version of Ruby and use it for commands executed beneath
# a project's working directory.
#
#   include ruby::default
#   ruby::version::directory { '/some/project': }
#
# Install Ruby 2.2.0-dev and use it for all commands executed by the vagrant
# user.
#
#   include ruby::default
#   ruby::version::user { 'vagrant': }
#
# Install the default version of Ruby and install all gems for a project
# defined in its Gemfile.
#
#   include ruby::default
#   ruby::bundle { '/some/project': }
#
# Install Ruby 2.2.0-dev and install all gems for a project defined in its
# Gemfile.
#
#   ruby::ruby { '2.2.0-dev': }
#   ruby::bundle { '/some/project': ruby => '2.2.0-dev' }
#
# Although the ruby::bundle resource will take care to execute using the right
# version of Ruby, you should generally pair it with a version resource to
# ensure consistency for environments outside of Puppet.
#
#   ruby::ruby { '2.2.0-dev': }
#   ruby::version::directory { '/some/project': ruby => '2.2.0-dev' }
#   ruby::bundle { '/some/project': ruby => '2.2.0-dev' }
#
# === Requires
#
# Requires rbenv module from https://github.com/justindowning/puppet-rbenv
#
class ruby {
    include rbenv

    $default_version = '2.1.2'
    $bin_dir = "${rbenv::install_dir}/shims"
    $gem_bin_dir = "${rbenv::install_dir}/shims"

    rbenv::plugin { 'sstephenson/ruby-build': }
}
