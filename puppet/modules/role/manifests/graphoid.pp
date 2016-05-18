# == Class: role::graphoid
# This role installs the graphoid service for server side graph rendering.
#
class role::graphoid {
    include ::graphoid

    # use local graphoid renderer
    mediawiki::settings { 'Graphoid':
        values => [
            # Using list declaration because of some weird escaping rules
            '$wgGraphImgServiceUrl = "/api/rest_v1/page/graph/png/%2\$s/%3\$s/%4\$s.png";',

            # TODO: if restbase is not set up, use this pattern (host, port, and server should be dynamic?)
            '$wgGraphImgServiceUrl = "//localhost:11042?server=%1\$s&title=%2\$s&revid=%3\$s&id=%4\$s";',
        ],
    }
}
