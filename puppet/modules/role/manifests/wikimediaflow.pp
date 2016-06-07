# -- Class: role::wikimediaflow
# Flow with a closer configuration to production
# Depends on role::flow
class role::wikimediaflow {
    require ::role::flow

    include ::role::antispam
    include ::role::checkuser
    include ::role::cldr
    include ::role::confirmedit
    include ::role::eventlogging
    include ::role::externalstore
    include ::role::betafeatures
    include ::role::varnish
    include ::role::visualeditor

    $privileged_username = 'Selenium Flow user'
    mediawiki::user { $privileged_username:
        password => $::mediawiki::admin_pass,
        wiki     => $::mediawiki::db_name,
        groups   => [
            'sysop',
            'suppress',
            'flow-creator',
        ],
    }

    $regular_username = 'Selenium Flow user 2'
    mediawiki::user { $regular_username:
        password => $::mediawiki::admin_pass,
        wiki     => $::mediawiki::db_name,
    }

    role::centralauth::migrate_user { [ $privileged_username, $regular_username ]: }

    mediawiki::settings { 'Wikimedia Flow':
        values   => [
            '$wgDefaultUserOptions[\'flow-editor\'] = \'visualeditor\';',
            '$wgFlowExternalStore = $wgDefaultExternalStore;',
        ],
        priority => 25, # Load after Flow extension
    }
}
