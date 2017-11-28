# == Class: ruby
#
# Provides versions of Ruby from system packages, gems, and installation of
# project dependencies via Bundler.
#
# === Examples
#
# Install the default version of Ruby.
#
#   include ruby::default
#
# Install Ruby 1.9.3.
#
#   ruby::ruby { '1.9.3': }
#
# Install Ruby 1.9.3 and any version of Nokogiri before 1.6.
#
#   ruby::ruby { '1.9.3': }
#   ruby::gem { 'nokogiri': ruby => '1.9.3', version => '<1.6' }
#
# Install the default version of Ruby and install gems for a project according
# to its Gemfile.
#
#   include ruby::default
#   ruby::bundle { '/some/project/directory': }
#
# Install Ruby 1.9.3 and install gems for a project according to its Gemfile.
#
#   ruby::ruby { '1.9.3': }
#   ruby::bundle { '/some/project/directory': ruby => '1.9.3' }
#
class ruby {
    $default_version = '2.0'
    $gem_bin_dir = '/usr/local/bin'

    file { '/etc/gemrc':
        content => 'gem: --no-ri --no-rdoc',
    }

    # Remove rbenv environment settings
    file { '/etc/profile.d/rbenv.sh':
        ensure => absent,
    }
}
