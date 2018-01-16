# == Class: role::proofreadpage
# Configures ProodreadPage, an extension to allow the proofreading of
# a text in comparison with scanned images.
class role::proofreadpage {
    include ::role::parserfunctions
    include ::role::labeledsectiontransclusion
    include ::role::cite

    require_package('djvulibre-bin')
    require_package('ghostscript')
    require_package('netpbm')

    php::ini { 'proofreadpage':
        settings => {
            upload_max_filesize => '50M',
            post_max_size       => '50M',
        },
    }

    mediawiki::extension { 'ProofreadPage':
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
        require      => [
            Package['djvulibre-bin', 'ghostscript', 'netpbm'],
            Mediawiki::Extension['LabeledSectionTransclusion', 'Cite'],
        ],
    }
}
