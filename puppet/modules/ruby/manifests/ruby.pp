# == Define: ruby::ruby
#
# Declare a version of Ruby that should be installed.
#
# === Examples
#
# Make sure Ruby version 2.1.2 is installed.
#
#   ruby::ruby { '2.1.2': }
#
define ruby::ruby {
    include ruby

    rbenv::build { $title: }
}
