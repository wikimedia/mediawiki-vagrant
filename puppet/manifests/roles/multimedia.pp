# == Class: role::multimedia
# This class configures MediaWiki for multimedia development.
# It is meant to contain general configuration of shared use to other
# extensions that are commonly used by the multimedia team in
# development and testing.
class role::multimedia {
    include role::mediawiki

    include packages::imagemagick

    # Increase PHP upload size from default puny 2MB
    php::ini { 'uploadsize':
        settings => {
            upload_max_filesize => '100M',
            post_max_size       => '100M',
        }
    }

    # Enable dynamic thumbnail generation via the thumb.php
    # script for 404 thumb images.
    mediawiki::settings { 'thumb.php on 404':
        values => {
            wgThumbnailScriptPath      => false,
            wgGenerateThumbnailOnParse => false,
            wgUseImageMagick           => true,
        },
    }

    apache::conf { 'thumb.php on 404':
        site    => $mediawiki::wiki_name,
        content => template('thumb_on_404.conf.erb'),
    }
}
