# == Class: role::thumb_on_404
# This class configures MediaWiki to generate image thumbnails automatically
# when an existing thumbnail is not found in cache.
class role::thumb_on_404 {
    require ::role::mediawiki

    require_package('imagemagick')

    role::thumb_on_404::multiwiki { $::mediawiki::wiki_name:
        images_url => '/images',
        images_dir => "${::mwv::files_dir}/images",
        wiki       => $::mediawiki::wiki_name,
    }
}
