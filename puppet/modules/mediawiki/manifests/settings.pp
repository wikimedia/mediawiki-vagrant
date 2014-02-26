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
define mediawiki::settings(
    $values,
    $ensure       = present,
    $priority     = 10,
    $header       = '',
    $footer       = '',
) {
    include mediawiki

    # make a safe filename based on our title
    $fname = inline_template('<%= @title.gsub(/\W/, "-") %>')
    $settings_file = sprintf('%s/%.2d-%s.php',
        $mediawiki::managed_settings_dir, $priority, $fname)

    file { $settings_file:
        ensure  => $ensure,
        content => template('mediawiki/settings.php.erb'),
        # Because the file resides on a shared folder, any other owner
        # or mode will cause VirtualBox and Puppet to play tug-o'-war
        # over the file.
        owner   => 'vagrant',
        group   => 'www-data',
        require => Exec['mediawiki setup'],
    }
}
