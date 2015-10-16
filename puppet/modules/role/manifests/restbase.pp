# == Class: role::restbase
# Provisions RESTBase, a REST content API service
class role::restbase {
    require ::role::parsoid
    require ::restbase

    # set up the update extension
    mediawiki::extension { 'RestBaseUpdateJobs':
        entrypoint => 'RestbaseUpdate.php',
        settings   => {
            wgRestbaseServer => "http://localhost:${::restbase::port}",
            wgRestbaseDomain => $::restbase::domain,
        },
    }

    # register the PHP Virtual REST Service connector
    mediawiki::settings { 'restbase-vrs':
        values   => template('role/restbase/vrs.php.erb'),
        priority => 4,
    }

    # let VE load stuff directly from RB if it's active
    mediawiki::settings { 'restbase-visualeditor':
        values   => {
            wgVisualEditorRestbaseURL =>
                "http://localhost:${::restbase::port}/${::restbase::domain}/v1/page/html/",
        },
        priority => 6,
    }

}

