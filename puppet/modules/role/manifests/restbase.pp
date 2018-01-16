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
# [*public_url*]
#   URL that should be used to link to the Swagger documentation page.
#
# [*ve_url*]
#   URL that VisualEditor should use to load a page via RESTBase
#   (example: '/api/rest_v1/my.wiki.domain/v1/page/html/')
#
class role::restbase (
    $base_url,
    $domain,
    $public_url,
    $ve_url,
) {
    require ::role::mediawiki
    include ::role::parsoid
    include ::role::eventbus
    include ::restbase
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http

    # Register the PHP Virtual REST Service connector
    mediawiki::settings { 'RESTBase-VRS':
        values   => template('role/restbase/vrs.php.erb'),
        priority => $::load_first,
        wiki     => $::mediawiki::wiki_name,
    }

    # Reverse proxy /api/rest_v1/ to RESTBase server
    apache::site_conf { 'RESTBase_Proxy':
        site    => 'devwiki',
        content => template('role/restbase/apache2.conf.erb'),
    }

    # Let VE load stuff directly from RB if it's active
    mediawiki::settings { 'RESTBase-VisualEditor':
        values   => {
            wgVisualEditorFullRestbaseURL => $base_url,
            wgVisualEditorRestbaseURL     => $ve_url,
        },
        priority => $::load_early,
        wiki     => $::mediawiki::wiki_name,
    }

    mediawiki::import::text { 'VagrantRoleRestbase':
        content => template('role/restbase/VagrantRoleRestbase.wiki.erb'),
    }
}

