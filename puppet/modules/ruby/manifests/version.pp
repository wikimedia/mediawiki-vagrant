# == Define: ruby::version
#
# A set of resources for declaring that a version of Ruby should be used in
# certain contexts. See the below examples or the ruby::version::* resources
# for details on each possible context.
#
# === Examples
#
# Use the default version of Ruby when executing commands anywhere below the
# /some/project directory.
#
#   ruby::version::directory { '/some/project': }
#
# Use Ruby 2.2.0-dev when executing commands as the vagrant user.
#
#   ruby::version::user { 'vagrant': ruby => '2.2.0-dev' }
#
class ruby::version {
    include ruby
}
