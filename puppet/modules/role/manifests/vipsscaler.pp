# == Class: role::vipsscaler
# Configures a MediaWiki instance with
# VipsScaler[https://www.mediawiki.org/wiki/Extension:VipsScaler]

class role::vipsscaler {
    require_package('libvips-tools')

    mediawiki::extension { 'VipsScaler':
        settings => {
            wgVipsOptions    => [
                {
                    conditions => {
                        mimeType => 'image/png',
                        minArea  => 20000000,
                    },
                },
                {
                    conditions => {
                        mimeType        => 'image/tiff',
                        minShrinkFactor => 1.2,
                        minArea         => 50000000,
                    },
                    sharpen    => {
                        sigma => 0.8,
                    },
                },
            ],
            wgMaxShellMemory => 1048576,
            wgMaxShellTime   => 50,
        },
    }

    mediawiki::settings { 'VipsTest':
        values => template('vipsscaler/vipstest.php.erb'),
    }
}
