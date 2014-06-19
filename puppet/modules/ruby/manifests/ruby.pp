# == Define: ruby::ruby
#
# Declare a version of Ruby that should be installed.
#
# === Examples
#
# Make sure Ruby version 1.9.3 is installed.
#
#   ruby::ruby { '1.9.3': }
#
define ruby::ruby {
    include ruby

    package { "ruby${title}":
        ensure => latest,
    }

    ruby::gem { "ruby${title}-bundler":
        gem  => 'bundler',
        ruby => $title,
    }
}
