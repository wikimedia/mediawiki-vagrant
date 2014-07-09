# == Class: role::thumb_on_404
# This class configures MediaWiki to generate image thumbnails automatically
# when an existing thumbnail is not found in cache.
class role::thumb_on_404 {
    include role::mediawiki
    include packages::imagemagick

    # Enable dynamic thumbnail generation via the thumb.php
    # script for 404 thumb images.
    mediawiki::settings { 'thumb.php on 404':
        values => {
            wgThumbnailScriptPath      => false,
            wgGenerateThumbnailOnParse => false,
            wgUseImageMagick           => true,
        },
    }

    apache::site_conf { 'thumb.php on 404':
        site    => $mediawiki::wiki_name,
        content => template('thumb_on_404.conf.erb'),
    }
}
