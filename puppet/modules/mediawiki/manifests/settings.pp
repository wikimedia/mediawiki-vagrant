# == Define: mediawiki::settings
#
# This resource type represents a collection of MediaWiki settings.
#
# === Parameters
#
# [*values*]
#   This parameter contains the configuration settings. Settings may be
#   specified as a hash, array, or string. See examples below. Empty by
#   default.
#
# [*wiki*]
#   Wiki to add settings for. The default will install the settings for all
#   wikis. The wiki name can also be specified in the resource's title as
#   'wiki:rest_of_title'.
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
# The following example configures the EventLogging MediaWiki settings and
# illustrates the use of hashes to specify settings:
#
#   mediawiki::settings { 'database debug':
#     values => {
#       'wgShowSQLErrors'        => true,
#       'wgDebugDumpSql'         => true,
#       'wgShowDBErrorBacktrace' => false,
#     },
#   }
#
# Note that the order of keys in a hash is unspecified. If the order matters to
# you, use an array or a string. The next example shows how settings may be
# specified as an array:
#
#   mediawiki::settings { 'database debug':
#     values => [
#       '$wgShowSQLErrors = true;',
#       '$wgDebugDumpSql = true;',
#       '$wgShowDBErrorBacktrace = false;',
#     ],
#   }
#
# Finally, 'settings' can also be specified as a string value. This can be
# especially powerful when used in combination with Puppet's template()
# function, as the following example illustrates:
#
#   mediawiki::settings { 'database debug':
#     values => template('db_debug/settings.php.erb'),
#   }
#
# If you have configured multiple wikis, settings can be applied to a particular
# wiki by either providing a value for the 'wiki' parameter:
#
#  mediawiki::settings { 'only for commons':
#    values => ...,
#    wiki   => 'commons',
#  }
#
# Or by starting the resource title with 'wiki_name:':
#
#  mediawiki::settings { 'commons:also for commons':
#    values => ...,
#  }
#
# By default, settings are applied to all wikis. If you have some settings
# that should *only* be applied to the default wiki, use
# `wiki => $::mediawki::wiki_name`.
#
define mediawiki::settings(
    $values,
    $wiki         = undef,
    $ensure       = present,
    $priority     = 10,
    $header       = '',
    $footer       = '',
) {
    include ::mediawiki
    require ::mediawiki::multiwiki

    # Set wiki from title if appropriate
    if $title =~ /^(\w+):(.+)$/ {
        $parts = split($title, ':')
        $wiki_name = $wiki ? {
            undef   => $parts[0],
            default => $wiki,
        }
        $settings_name = $parts[1]

    } else {
        $wiki_name = $wiki
        $settings_name = $title
    }

    if $wiki_name == $::mediawiki::wiki_name {
        $db_name = $::mediawiki::db_name
    } elsif $wiki_name =~ String and $wiki_name =~ /wiki$/ {
        $db_name = $wiki_name
    } else {
        $db_name = "${wiki_name}wiki"
    }

    # Determine collection to place settings in: shared or wiki specific
    $dir = $wiki_name ? {
        undef   => $::mediawiki::managed_settings_dir,
        default => "${::mediawiki::multiwiki::settings_root}/${db_name}/settings.d/puppet-managed",
    }

    # make a safe filename based on our title
    $fname = inline_template('<%= @settings_name.gsub(/\W/, "-") %>')
    $settings_file = sprintf('%s/%.2d-%s.php', $dir, $priority, $fname)

    file { $settings_file:
        ensure  => $ensure,
        content => template('mediawiki/settings.php.erb'),
        owner   => $::share_owner,
        group   => $::share_group,
    }

    if $wiki_name {
      # Ensure that wiki is created before adding settings
      Mediawiki::Wiki[$wiki_name] -> File[$settings_file]
    }
}
