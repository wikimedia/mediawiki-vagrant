# vim:set sw=4 ts=4 sts=4 et:

# == Define: multiwiki::settings
#
# Add MediaWiki settings for a specific multiwiki instance. Wraps
# mediawiki::settings.
#
# The resource title must be in the form "wiki:description" where "wiki" is the
# resource title of a multiwiki::wiki declaration (e.g. "login") and
# "description" is any non-empty string.
#
# === Parameters
#
# [*values*]
#   This parameter contains the configuration settings. Settings may be
#   specified as a hash, array, or string. See examples below. Empty by
#   default.
#
# [*ensure*]
#   If 'present' (the default), Puppet will install the settings. If
#   'absent', Puppet will delete its configuration file.
#
# [*priority*]
#   This parameter takes a numeric value, which is used to generate a
#   prefix for the configuration snippet. Settings managed by Puppet will
#   load in order of priority, with smaller values loading first. The
#   default is 10. You only need to override the default if you want
#   these settings to load before or after some other settings.
#
# [*header*]
#   Block of PHP code or documentation to stick in the settings file.
#   The content will be added *before* the settings values. Empty by
#   default.
#
# [*footer*]
#   Block of PHP code or documentation to stick in the settings file.
#   The content will be added *after* the settings values. Empty by
#   default.
#
# === Examples
#
#   multiwiki::settings { 'example:database debug':
#     values => {
#       'wgShowSQLErrors'        => true,
#       'wgDebugDumpSql'         => true,
#       'wgShowDBErrorBacktrace' => false,
#     },
#   }
#
# See mediawiki::settings for more examples.
#
define multiwiki::settings(
    $values,
    $ensure       = present,
    $priority     = 10,
    $header       = '',
    $footer       = '',
) {
    include ::multiwiki

    # Validate $title
    if $title !~ /^(\w+):(.+)$/ {
      fail('Multiwiki::settings titles must begin with "<wiki>:".')
    }

    $parts = split($title, ':')
    $wiki = $parts[0]
    $wikidb = "${wiki}wiki"
    $settings_dir = "${::multiwiki::settings_root}/${wikidb}/settings.d"

    mediawiki::settings { $title:
        ensure       => $ensure,
        values       => $values,
        priority     => $priority,
        header       => $header,
        footer       => $footer,
        settings_dir => "${settings_dir}/puppet-managed",
        require      => Multiwiki::Wiki[$wiki],
    }
}
