# == Class: role::pagedtiffhandler
# This role provisions the PagedTiffHandler[https://www.mediawiki.org/wiki/Extension:PagedTiffHandler] extension,
# which improves the handling of TIFF files.
class role::pagedtiffhandler {
    include role::mediawiki
    include role::multimedia
    include packages::exiv2
    include packages::libtiff_tools

    mediawiki::extension { 'PagedTiffHandler':
        require  => Package['exiv2', 'libtiff-tools'],
        settings => {
            wgTiffUseTiffinfo => true,
        }
    }
}
