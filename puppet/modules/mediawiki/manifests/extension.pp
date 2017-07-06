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
# [*wiki*]
#   Wiki to add settings for. The default will install the settings for all
#   wikis. The wiki name can also be specified in the resource's title as
#   'wiki:rest_of_title'.
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
# [*browser_tests*]
#   Whether or not to install the dependencies necessary to execute browser
#   tests. Specifying true will bundle the tests in the default
#   'tests/browser' subdirectory of the extension directory. You may otherwise
#   provide a different subdirectory, or false to skip installation of
#   browser-test dependencies altogether. Default: false.
#
# [*composer*]
#   Whether this extension has dependencies that need to be installed via
#   Composer. Default: false.
#
# [*remote*]
#   Remote URL for the repository. Passed to git::clone if set. See
#   git::deploy docs for more details.
#
# === Examples
#
# The following example configures the EventLogging MediaWiki extension and
# illustrates the use of hashes to specify settings:
#
#   mediawiki::extension { 'EventLogging':
#     settings => {
#       wgEventLoggingBaseUri => '/event.gif',
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
# If you have configured multiple wikis, an extension can be eanbled for
# a particular wiki by either providing a value for the 'wiki' parameter:
#
#  mediawiki::extension { 'SomeCoolExtension':
#    wiki     => 'commons',
#    settings => ...,
#  }
#
# Or by starting the resource title with 'wiki_name:':
#
#  mediawiki::extension { 'commons:SomeCoolExtension':
#    values => ...,
#  }
#
# By default, extensions are installed for all wikis. If you have some
# extensions that should *only* be applied to the default wiki, use
# `wiki => $::mediawki::wiki_name`.
#
define mediawiki::extension(
    $ensure         = present,
    $wiki           = undef,
    $extension      = undef,
    $entrypoint     = undef,
    $priority       = 10,
    $needs_update   = false,
    $branch         = undef,
    $settings       = {},
    $browser_tests  = false,
    $composer       = false,
    $remote         = undef,
) {
    include ::mediawiki

    $mwbranch = $branch ? {
      undef   => $::mediawiki::branch,
      default => $branch,
    }

    # Set wiki from title if appropriate
    if $title =~ /^(\w+):(.+)$/ {
        $parts = split($title, ':')
        $ext_wiki = $wiki ? {
            undef   => $parts[0],
            default => $wiki,
        }
        $ext_name = $extension ? {
            undef   => $parts[1],
            default => $extension,
        }

    } else {
        $ext_name = $extension ? {
            undef   => $title,
            default => $extension,
        }
        $ext_wiki = $wiki
    }

    $ext_entrypoint = $entrypoint ? {
        undef   => "${ext_name}.php",
        default => $entrypoint,
    }

    $ext_dir = "${mediawiki::dir}/extensions/${ext_name}"
    $ext_repo = "mediawiki/extensions/${ext_name}"

    git::clone { $ext_repo:
        directory => $ext_dir,
        branch    => $mwbranch,
        remote    => $remote,
        require   => Git::Clone['mediawiki/core'],
    }

    mediawiki::settings { $title:
        ensure   => $ensure,
        wiki     => $ext_wiki,
        header   => template('mediawiki/extension.php.erb'),
        footer   => '}', # Close if opened in header
        values   => $settings,
        priority => $priority,
        require  => Git::Clone[$ext_repo],
    }

    if $composer {
        php::composer::install{ $ext_dir:
            prefer  => 'source',
            require => Git::Clone[$ext_repo],
        }

        Php::Composer::Install[$ext_dir] ~> Mediawiki::Settings[$title]
    }

    if $needs_update {
        # If the extension requires a schema migration, set up the
        # settings file resource to notify update.php.
        Mediawiki::Settings[$title] ~> Exec['update_all_databases']
    }

    if $browser_tests {
        mediawiki::extension::browsertests { $ext_name:
            path => $browser_tests,
        }
    }
}
