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
define env::profile_script(
    $ensure   = present,
    $priority = 50,
    $content  = undef,
    $source   = undef,
) {
    include ::env

    if $priority !~ Integer[0, 99] {
        fail('"priority" must be between 0 - 99')
    }
    if $ensure !~ /^(present|absent)$/ {
        fail('"ensure" must be "present" or "absent"')
    }

    $safe_name   = regsubst($title, '[\W_]', '-', 'G')
    $script_file = sprintf('%02d-%s', $priority, $safe_name)

    file { "/etc/profile.d/${script_file}.sh":
        ensure  => $ensure,
        content => $content,
        source  => $source,
    }
}
