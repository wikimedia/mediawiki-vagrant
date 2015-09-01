# == Class: role::thumbor
# Installs a Thumbor instance
#
class role::thumbor (
) {
    include ::thumbor

    mediawiki::settings { 'thumbor':
        values => [
            '$wgThumbnailingService = array("type" => "thumbor", "uri" => "http://127.0.0.1:8888/unsafe/", "dimensionsSeparator" => "x", "sourceParameter" => "/",);',
        ],
    }
}

