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

    mediawiki::extension { 'Sentry':
        settings => [
            # OMG that's ugly. Did not find a better way to reuse
            # the output of a script.
            "\$wgSentryDsn = file_get_contents('${dsn}');",
        ],
    }

    mediawiki::extension { 'Buggy': }

    mediawiki::import_text{ 'VagrantRoleSentry':
        source => 'puppet:///modules/role/VagrantRoleSentry.wiki',
    }
}
