# == Class: role::pdfhandler
#
# The PdfHandler extension shows uploaded PDF files in a multipage
# preview layout. With the Proofread Page extension enabled, PDFs can be
# displayed side-by-side with text for transcribing books and other
# documents, as is commonly done with DjVu files (particularly in
# Wikisource).
class role::pdfhandler {
    include ::role::multimedia

    require_package('ghostscript')
    require_package('imagemagick')
    require_package('poppler-utils')

    mediawiki::extension { 'PdfHandler':
        needs_update => true,
        require      => Package['ghostscript', 'imagemagick', 'poppler-utils'],
        settings     => [
            '$wgEnableUploads = true',
            '$wgFileExtensions[] = \'pdf\'',
        ],
    }
}
