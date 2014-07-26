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

    $images_path = '/images'
    apache::site_conf { 'thumb.php on 404':
        site    => $::mediawiki::wiki_name,
        content => template('thumb_on_404.conf.erb'),
    }
}

# == Define: ::role::thumb_on_404::multiwiki
# Configure a multiwiki instance with thumbs on 404.
# See commons.pp
define role::thumb_on_404::multiwiki {
    $images_path = "/${title}images"
    apache::site_conf { "${title}:thumb.php on 404":
        site    => $::mediawiki::wiki_name,
        content => template('thumb_on_404.conf.erb'),
    }
}
