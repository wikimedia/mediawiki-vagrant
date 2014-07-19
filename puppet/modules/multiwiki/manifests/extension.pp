# vim:set sw=4 ts=4 sts=4 et:

# == Define: multiwiki::extension
#
# Install and enable an extension for a specific multiwiki instance. Wraps
# mediawiki::extension.
#
# The resource title must be in the form "wiki:extension" where "wiki" is the
# resource title of a multiwiki::wiki declaration (e.g. "login") and
# "extension" is the canonical name for the extension (e.g. "CentralAuth").
#
# === Parameters
#
# [*ensure*]
#   If 'present' (the default), Puppet will install the extension. If
#   'absent', Puppet will delete its configuration file, but it will not
#   delete the cloned Git repository which contains the extension's
#   files.
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
#   Settings may be specified as a hash, array, or string. See
#   mediawiki::extension and mediawiki::settings for detailed examples. Empty
#   by default.
#
# [*browser_tests*]
#   Whether or not to install the dependencies necessary to execute browser
#   tests. Specifying true will bundle the tests in the default
#   'tests/browser' subdirectory of the extension directory. You may otherwise
#   provide a different subdirectory, or false to skip installation of
#   browser-test dependencies altogether. Default: false.
#
# === Examples
#
#   multiwiki::extension { 'examplemulti:Example':
#       settings => {
#           wgFoo => true,
#           wgBar => 'bar',
#       },
#   }
#
# See mediawiki::extension for additional examples.
#
define multiwiki::extension(
    $ensure       = present,
    $entrypoint   = undef,
    $priority     = 10,
    $needs_update = false,
    $branch       = undef,
    $settings     = {},
    $browser_tests  = false,
) {
    include ::multiwiki

    # Validate $title
    if $title !~ /^(\w+):(\w+)$/ {
      fail('Multiwiki::extension titles must be in the form "<wiki>:<extension>".')
    }

    $parts = split($title, ':')
    $wiki = $parts[0]
    $extension = $parts[1]

    $wikidb = "${wiki}wiki"

    $ext_entrypoint = $entrypoint ? {
        undef   => "${extension}.php",
        default => $entrypoint,
    }

    $settings_dir = "${::multiwiki::settings_root}/${wikidb}/settings.d"

    mediawiki::extension { $title:
        ensure        => present,
        extension     => $extension,
        entrypoint    => $ext_entrypoint,
        priority      => $priority,
        needs_update  => false,
        branch        => $branch,
        settings      => $settings,
        settings_dir  => "${settings_dir}/puppet-managed",
        browser_tests => $browser_tests,
    }

    if $needs_update {
        # If the extension requires a schema migration, set up the
        # settings file resource to notify update.php.
        Mediawiki::Settings[$title] ~> Exec["update ${wikidb} database"]
    }
}
