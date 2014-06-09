# == Define: ruby::default
#
# Ensures the default version of Ruby (as defined by $ruby::default_version)
# is installed.
#
class ruby::default {
    include ruby

    ruby::ruby { $ruby::default_version: }
}
