# == Class: role::mysql_strict
# Configures MySQL/MariaDB to use strict mode.
# See https://phabricator.wikimedia.org/T112637
# Note: this is meant for testing new code.
# Not all old code is updated to work in strict mode yet.
#
class role::mysql_strict {
    mediawiki::settings { 'mysql_strict':
        values => {
            wgSQLMode => 'TRADITIONAL,ONLY_FULL_GROUP_BY',
        },
    }
}

