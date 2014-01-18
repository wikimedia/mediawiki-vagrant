# == Define: mediawiki::extension
#
# This resource type represents a MediaWiki extension. Declaring an
# extension to Puppet will cause Puppet to retrieve the extension code
# from Gerrit and configure MediaWiki to load it.
#
# === Parameters
#
# [*ensure*]
#   If 'present' (the default), Puppet will install the extension. If
#   'absent', Puppet will delete its configuration file, but it will not
#   delete the cloned Git repository which contains the extension's
#   files.
#
# [*extension*]
#   The canonical name for the extension. This value is used to generate
#   sensible defaults for the installation path and Gerrit repository
#   name. Defaults to the resource title.
#
# [*entrypoint*]
#   The path to the extension's entry point relative to the extension's
#   root directory. Defaults to '<Extension name>.php'. The default
#   value works for the vast majority of MediaWiki extensions.
#
# [*priority*]
#   This parameter takes a numeric value, which is used to generate a
#   prefix for the loader snippet. Extensions managed by Puppet will
#   load in order of priority, with smaller values loading first. The
#   default is 10. You only need to override the default if you want
#   this extension to load before or after some other extension.
#
# [*needs_update*]
#   If true, run MediaWiki's database update maintenance script
#   (maintenance/update.php) after configuring the extension. False by
#   default.
#
# [*branch*]
#   Specifies which branch of the extension's Git repository should be
#   cloned. Defaults to 'master'.
#
# [*settings*]
#   This parameter contains configuration settings for the extension.
#   Settings may be specified as a hash, array, or string. See examples
#   below. Empty by default.
#
# === Examples
#
# The following example configures the EventLogging MediaWiki extension and
# illustrates the use of hashes to specify settings:
#
#   mediawiki::extension { 'EventLogging':
#     settings => {
#       wgEventLoggingBaseUri        => "http://localhost:8181/event.gif",
#       wgEventLoggingDBname         => "testwiki",
#       wgEventLoggingFile           => 'udp://127.0.0.1:1234/EventLogging',
#       wgEventLoggingSchemaIndexUri => 'http://meta.wikimedia.org/w/index.php',
#     },
#   }
#
# Note that the order of keys in a hash is unspecified. If the order matters to
# you, use an array or a string. The next example shows how settings may be
# specified as an array:
#
#   mediawiki::extension { 'MobileFrontend':
#     settings => [
#       '$wgMFEnableResourceLoader = true;',
#       '$wgMFLogEvents = true;',
#     ],
#   }
#
# Finally, 'settings' can also be specified as a string value. This can be
# especially powerful when used in combination with Puppet's template()
# function, as the following example illustrates:
#
#   mediawiki::extension { 'Math':
#     settings => template('math/settings.php.erb'),
#   }
#
define mediawiki::extension(
    $ensure       = present,
    $extension    = $title,
    $entrypoint   = "${title}.php",
    $priority     = 10,
    $needs_update = false,
    $branch       = undef,
    $settings     = {},
) {
    include mediawiki

    git::clone { "mediawiki/extensions/${extension}":
        directory => "${mediawiki::dir}/extensions/${extension}",
        branch    => $branch,
        require   => Git::Clone['mediawiki/core'],
    }

    mediawiki::settings { $extension:
        ensure       => $ensure,
        header       => sprintf('include_once "$IP/extensions/%s/%s";', $extension, $entrypoint),
        values       => $settings,
        priority     => $priority,
        require      => Git::Clone["mediawiki/extensions/${extension}"],
    }

    if $needs_update {
        # If the extension requires a schema migration, set up the
        # settings file resource to notify update.php.
        Mediawiki::Settings[$extension] ~> Exec['update database']
    }
}
