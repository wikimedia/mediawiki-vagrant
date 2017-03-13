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
# [*missing_ok*]
#   Don't fail on account of a missing Gemfile.
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
define ruby::bundle(
    $directory  = $title,
    $gemfile    = undef,
    $missing_ok = false,
    $user       = 'vagrant',
) {
    include ::ruby

    $bundle = "ruby -- ${ruby::gem_bin_dir}/bundle"
    $bundle_gemfile = $gemfile ? {
        undef   => "${directory}/Gemfile",
        default => $gemfile,
    }

    $guard = $missing_ok ? {
        false   => '',
        default => "test ! -e '${bundle_gemfile}' || ",
    }

    # ensure there's no .bundle/config interferring
    file { "${directory}/.bundle/config":
        ensure => absent,
    }

    exec { "bundle_install_${title}":
        command     => "${bundle} install",
        provider    => 'shell',
        cwd         => $directory,
        environment => "BUNDLE_GEMFILE=${bundle_gemfile}",
        user        => $user,
        unless      => "${guard}${bundle} check",
        timeout     => 60 * 20,
        require     => [
            File["${directory}/.bundle/config"],
        ],
    }
}
