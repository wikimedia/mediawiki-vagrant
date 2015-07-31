# == Class: role::graphoid
# This role installs the graphoid service for server side graph rendering.
#
class role::graphoid {
    require ::graphoid::install::git
    # use local graphoid renderer
    mediawiki::settings { 'Graphoid':
        # lint:ignore:80chars
        values => [
            '$wgGraphImgServiceUrl = "//$wgServerName:11042?server=%1\$s&title=%2\$s&revid=%3\$s&id=%4\$s";',
        ],
        # lint:endignore
    }
}
