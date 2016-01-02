# == Define: mediawiki::maintenance
#
# This resource type represents a MediaWiki maintenance script that needs to be run.
#
# It is a wrapper around exec that ensures that the MediaWiki settings
# files are in place before the script runs.
#
# It can either be a single-wiki or all-wiki script.  The full command
# is specified in the format exec accepts.
#
# See exec resource for parameter documentation.
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
    $user        = undef,
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
        user        => $user,
    }

    # Make sure all Puppet-defined PHP settings are in place before
    # running maintenance scripts.
    Mediawiki::Settings <| |> -> Mediawiki::Maintenance <| |>
}
