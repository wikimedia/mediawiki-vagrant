# == Class: role::restbase
# Provisions RESTBase, a REST content API service
#
# Note: this role is not multiwiki aware and will only work on the default
# wiki.
#
# === Parameters
#
# [*base_url*]
#   Base URL of RESTbase (example: 'http://mywiki.net:8080/api/rest_').
#
# [*domain*]
#   RESTBase domain to serve
#
# [*ve_url*]
#   Url that VisualEditor should use to load a page via RESTBase
#   (example: '/api/rest_v1/my.wiki.domain/v1/page/html/')
class role::restbase (
    $base_url,
    $domain,
    $ve_url,
) {
    require ::role::mediawiki
    include ::role::parsoid
    include ::restbase
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http

    # Set up the update extension
    mediawiki::extension { 'RestBaseUpdateJobs':
        entrypoint => 'RestbaseUpdate.php',
        settings   => {
            wgRestbaseServer => "http://127.0.0.1:${::restbase::port}",
            wgRestbaseDomain => $::restbase::domain,
        },
        wiki       => $::mediawiki::wiki_db,
    }

    # Register the PHP Virtual REST Service connector
    mediawiki::settings { 'RESTBase-VRS':
        values   => template('role/restbase/vrs.php.erb'),
        priority => $::LOAD_FIRST,
        wiki     => $::mediawiki::wiki_db,
    }

    # Reverse proxy /api/rest_v1/ to RESTBase server
    apache::site_conf { 'RESTBase_Proxy':
        site    => 'devwiki',
        content => template('role/restbase/apache2.conf.erb'),
    }

    # Let VE load stuff directly from RB if it's active
    mediawiki::settings { 'RESTBase-VisualEditor':
        values   => {
            wgVisualEditorFullRestbaseURL => "${base_url}v1/${domain}/",
            wgVisualEditorRestbaseURL     => $ve_url,
        },
        priority => $::LOAD_EARLY,
        wiki     => $::mediawiki::wiki_db,
    }
}

