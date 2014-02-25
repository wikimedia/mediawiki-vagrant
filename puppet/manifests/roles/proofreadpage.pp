# == Class: role::proofreadpage
# Configures ProodreadPage, an extension to allow the proofreading of
# a text in comparison with scanned images.
class role::proofreadpage {
    include role::mediawiki
    include role::parserfunctions

    include packages::djvulibre_bin
    include packages::ghostscript
    include packages::netpbm

    php::ini { 'proofreadpage':
        settings => {
            upload_max_filesize => '50M',
            post_max_size       => '50M',
        },
    }

    mediawiki::extension { [ 'LabeledSectionTransclusion', 'Cite' ]:
        before => Mediawiki::Extension['ProofreadPage'],
    }

    mediawiki::extension { 'ProofreadPage':
        require      => Package['djvulibre-bin', 'ghostscript', 'netpbm'],
        needs_update => true,
        settings     => [
            '$wgEnableUploads = true',
            '$wgFileExtensions[] = "djvu"',
            '$wgFileExtensions[] = "pdf"',
            '$wgDjvuDump = "djvudump"',
            '$wgDjvuRenderer = "ddjvu"',
            '$wgDjvuTxt = "djvutxt"',
            '$wgDjvuPostProcessor = "ppmtojpeg"',
            '$wgDjvuOutputExtension = "jpg"',
        ],
    }
}
