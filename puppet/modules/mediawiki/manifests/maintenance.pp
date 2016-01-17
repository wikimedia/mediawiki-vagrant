# == Define: mediawiki::maintenance
#
# This resource type represents a MediaWiki maintenance script that needs to
# be run. This resource will alwyas run the named script as the www-data user
# and require that all settings files are provisioned and database updates
# have been run.
#
# It is a wrapper around exec that ensures that the MediaWiki settings
# files are in place before the script runs.
#
# It can either be a single-wiki or all-wiki script.  The full command
# is specified in the format exec accepts.
#
# See Puppet's built-in exec resource for parameter documentation.
define mediawiki::maintenance(
    $command,
    $creates     = undef,
    $cwd         = undef,
    $environment = undef,
    $group       = undef,
    $logoutput   = undef,
    $onlyif      = undef,
    $path        = undef,
    $refresh     = undef,
    $refreshonly = undef,
    $timeout     = undef,
    $unless      = undef,
) {

    exec { $title:
        command     => $command,
        creates     => $creates,
        cwd         => $cwd,
        environment => $environment,
        group       => $group,
        logoutput   => $logoutput,
        onlyif      => $onlyif,
        path        => $path,
        refresh     => $refresh,
        refreshonly => $refreshonly,
        timeout     => $timeout,
        unless      => $unless,
        # Maintenance scripts always run as the www-data user
        user        => 'www-data',
        # Always wait for the databases to get setup
        require     => Exec['update_all_databases'],
    }

    # Make sure all Puppet-defined PHP settings are in place before
    # running maintenance scripts.
    Mediawiki::Settings <| |> -> Mediawiki::Maintenance <| |>
}
