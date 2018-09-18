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

    mediawiki::settings { 'Wikimedia Flow':
        values   => [
            '$wgDefaultUserOptions[\'flow-editor\'] = \'visualeditor\';',
            '$wgFlowExternalStore = $wgDefaultExternalStore;',
        ],
        priority => 25, # Load after Flow extension
    }
}
