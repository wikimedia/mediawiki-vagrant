# == Class: role::pdfhandler
#
# The PdfHandler extension shows uploaded PDF files in a multipage
# preview layout. With the Proofread Page extension enabled, PDFs can be
# displayed side-by-side with text for transcribing books and other
# documents, as is commonly done with DjVu files (particularly in
# Wikisource).
class role::pdfhandler {
    include role::multimedia

    include packages::ghostscript
    include packages::poppler_utils
    include packages::imagemagick

    mediawiki::extension { 'PdfHandler':
        needs_update => true,
        require      => Package['ghostscript', 'imagemagick', 'poppler-utils'],
        settings     => [
            '$wgEnableUploads = true',
            '$wgMaxShellMemory = 300000',
            '$wgFileExtensions[] = \'pdf\'',
        ],
    }
}
