# == Class: role::copyvio
# Configures Copyvio, a MediaWiki extension to check for copyright violations
#
class role::copyvio {
    require ::role::mediawiki

    mediawiki::extension { 'Copyvio':
        needs_update => true,
    }

    mediawiki::settings { 'PageTriage-Copyvio':
        values => {
            'wgPageTriageShowCopyvio' => true,
        },
    }
}
