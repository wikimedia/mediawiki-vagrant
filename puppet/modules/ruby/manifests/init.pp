# == Class: ruby
#
# Provides versions of Ruby from system packages, gems, and installation of
# project dependencies via Bundler.
#
class ruby {
    $gem_bin_dir = '/usr/bin'

    require_package('ruby', 'ruby-dev', 'bundler')

    # Remove rbenv environment settings
    file { '/etc/profile.d/rbenv.sh':
        ensure  => absent,
        require => Package['ruby'],
    }

    file { '/etc/gemrc':
        content => 'gem: --no-ri --no-rdoc',
    }
}
