# == Define: motd::script
#
# Provision a message-of-the-day script.
#
# === Parameters
#
# [*priority*]
#   If you need this script to load before or after other scripts, you
#   can make it do so by manipulating this value. In most cases, the
#   default value of 50 should be fine.
#
# [*content*]
#   If defined, will be used as the content of the motd script.
#   Undefined by default. Mutually exclusive with 'source'.
#
# [*source*]
#   Path to motd script. Undefined by default. Mutually exclusive
#   with 'content'.
#
# === Examples
#
#  motd::script { 'mediawiki_vagrant':
#    ensure   => present,
#    content  => "echo 'You are using MediaWiki-Vagrant!'\n",
#    priority => 60,
#  }
#
define motd::script(
    $ensure    = present,
    $priority  = 50,
    $content   = undef,
    $source    = undef,
) {
    include ::motd

    if $priority !~ Integer[0, 99] {
        fail('"priority" must be between 0 - 99')
    }
    if $ensure !~ /^(present|absent)$/ {
        fail('"ensure" must be "present" or "absent"')
    }

    $safe_name = regsubst($title, '[\W_]', '-', 'G')
    $script    = sprintf('%02d-%s', $priority, $safe_name)

    file { "/etc/update-motd.d/${script}":
        ensure  => $ensure,
        mode    => '0555',
        content => $content,
        source  => $source,
    }
}
