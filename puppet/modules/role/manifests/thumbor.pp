# == Class: role::thumbor
# Installs a Thumbor instance
#
class role::thumbor (
) {
    include ::thumbor

    mediawiki::settings { 'thumbor':
        values => [
            '$wgThumbnailingService = array("type" => "thumbor", "host" => "127.0.0.1", "port" => 8888, "path" => "/unsafe/", "dimensionsSeparator" => "x", "sourceParameter" => "/",);',
        ],
    }
}

