# == Class: role::multimedia
# This class configures MediaWiki for multimedia development:
# - installs ImageMagick
# - raises file size limits
# - raises image MP limit
# - configures 404-handler[https://www.mediawiki.org/wiki/Manual:Thumb.php#404_Handler]
# - installs exiftool
# It is meant to contain general configuration of shared use to other
# extensions that are commonly used by the multimedia team in
# development and testing.
class role::multimedia {
    include ::role::thumb_on_404

    require_package('imagemagick')
    require_package('libimage-exiftool-perl')

    # Increase PHP upload size from default puny 2MB
    php::ini { 'uploadsize':
        settings => {
            upload_max_filesize => '100M',
            post_max_size       => '100M',
        }
    }

    mediawiki::settings { 'multimedia':
        require => Package['imagemagick'],
        values  => {
            # These are copied over from the Commons production configuration
            wgMaxImageArea               => 75e6,
            wgTiffMaxMetaSize            => 1048576,
            wgMaxAnimatedGifArea         => 75e6,
            wgSharpenParameter           => '0x0.8',
            wgUseImageMagick             => true,
            wgUseTinyRGBForJPGThumbnails => true,
            wgUploadThumbnailRenderMap   => [ 320, 640, 800, 1024, 1280, 1920, 2560, 2880 ],
        }
    }
}
