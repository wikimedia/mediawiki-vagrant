# == Define: apt::pin
#
# Sets up an APT pin priority for the given packages. See `man 5
# apt_preferences` for details on pinning.
#
# === Parameters
#
# [*pin*]
#   Package properties to match against.
#
# [*priority*]
#   Pin priority.
#
# [*package*]
#   Package name or pattern. Default: $name.
#
# [*ensure*]
#   Whether or not the preference should exist.
#
# === Examples
#
# Ensure Wikimedia packages are installed over those from dist sources.
#
#   apt::pin { 'wikimedia':
#       package  => '*',
#       pin      => 'release o=Wikimedia',
#       priority => 1001,
#   }
#
define apt::pin (
    $pin,
    $priority,
    $package = $name,
    $ensure = present,
) {
    # Validate that $name does not already have a ".pref" suffix.
    if $name =~ /\.pref$/ {
        fail('$name must not have a ".pref" suffix.')
    }

    file { "/etc/apt/preferences.d/${name}.pref":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => "Package: ${package}\nPin: ${pin}\nPin-Priority: ${priority}\n",
        notify  => Exec['apt-get update'],
    }
}
