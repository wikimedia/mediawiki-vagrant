# == Define: ruby::bundle
#
# Installs gem dependencies according to the given directory's Gemfile.
#
# === Parameters
#
# [*directory*]
#   Project directory containing Gemfile. Default: $title.
#
# [*gemfile*]
#   A specific path to the Gemfile. Default: "$directory/Gemfile".
#
# [*path*]
#   Gem installation path. By default, gems are isolated to a path below the
#   directory. Default: "$directory/.gem".
#
# [*ruby*]
#   Version of Ruby. Default: $ruby::default_version
#
# [*user*]
#   The user to run bundler commands as. Default: 'vagrant'.
#
# === Examples
#
# Ensure dependencies are installed for browsertests.
#
#   ruby::bundle { '/srv/browsertests/test/browser': }
#
# Same as the above, but install gems to a shared location.
#
#   ruby::bundle { '/srv/browsertests/test/browser': path => '/home/vagrant/.gem' }
#
define ruby::bundle(
    $directory = $title,
    $gemfile   = undef,
    $path      = '.gem',
    $ruby      = $ruby::default_version,
    $user      = 'vagrant',
) {
    include ruby

    $bundle = "ruby${ruby} -- ${ruby::gem_bin_dir}/bundle"

    $bundle_gemfile = $gemfile ? { undef => "${directory}/Gemfile", default => $gemfile }

    exec { "bundle-install-${title}":
        command     => "$bundle install --path '${path}'",
        provider    => 'shell',
        cwd         => $directory,
        environment => [
            "BUNDLE_GEMFILE=${bundle_gemfile}",
        ],
        user        => $user,
        unless      => "$bundle check",
        timeout     => 60 * 20,
        require     => Ruby::Ruby[$ruby],
    }
}
