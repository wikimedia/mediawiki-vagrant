# == Class: role::sentry
# Installs a Sentry instance which collects errors from your wiki
#
# [*dsn*]
#   The Sentry DSN to use, see
#   http://raven.readthedocs.org/en/latest/config/#the-sentry-dsn
#
class role::sentry (
    $dsn,
) {
    include ::sentry
    include ::role::buggy

    $hostname = $::sentry::vhost_name

    mediawiki::extension { 'Sentry':
        settings => [
            # OMG that's ugly. Did not find a better way to reuse
            # the output of a script.
            "\$wgSentryDsn = trim(file_get_contents('${dsn}'));",
        ],
        composer => true,
    }

    mediawiki::import::text { 'VagrantRoleSentry':
        content => template('role/sentry/VagrantRoleSentry.wiki.erb'),
    }
}

