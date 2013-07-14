# == Define: env::profile
#
# This Puppet resource represents an /etc/profile.d shell script. These
# scripts are typically used to initialize the shell environment.
#
# === Parameters
#
# [*content*]
#   The desired content of the script, provided as a string. Either this
#   or 'source' (but not both) must be defined.
#
# [*source*]
#   URI of Puppet file or path reference to a local file that should be
#   copied over to create this script. Either this or 'content' must be
#   defined.
#
# [*script*]
#   A short, descriptive name for the script, used to generate the
#   filename. Defaults to the resource name.
#
# [*ensure*]
#   If 'present' (the default), Puppet will ensure the script is in
#   place. If 'absent', Puppet will remove it.
#
# === Example
#
#  env::profile { 'set python env vars':
#      source => 'puppet:///modules/python/env-vars.sh',
#  }
#
define env::profile(
    $content = undef,
    $source  = undef,
    $script  = $title,
    $ensure  = present,
) {
    include env

    $script_name = regsubst($script, '\W', '_', 'G')
    file { "/etc/profile.d/puppet-managed/${script_name}.sh":
        ensure  => $ensure,
        mode    => '0755',
        content => $content,
        source  => $source,
    }
}
