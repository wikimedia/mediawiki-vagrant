# == Class: role::uploadwizard
# Configures a MediaWiki instance with UploadWizard[https://www.mediawiki.org/wiki/Extension:UploadWizard], a JavaScript-driven
# wizard interface for uploading multiple files.
class role::uploadwizard {
    include role::mediawiki
    include role::eventlogging
    include role::multimedia
    include role::codeeditor

    # API smoke test dependencies
    include packages::python_imaging
    include packages::python_poster
    include packages::python_wikitools
    include packages::imagemagick

    mediawiki::extension { 'Campaigns': }

    mediawiki::extension { 'UploadWizard':
        require  => Package['imagemagick'],
        settings => {
            wgEnableUploads       => true,
            wgUseImageMagick      => true,
            wgUploadNavigationUrl => '/wiki/Special:UploadWizard',
            wgUseInstantCommons   => true,
            wgApiFrameOptions     => 'SAMEORIGIN',
            wgUploadWizardConfig  => {
              altUploadForm       => 'Special:Upload',
              autoCategory        => 'Uploaded with UploadWizard',
              enableChunked       => 'opt-in',
              enableFormData      => true,
              enableMultipleFiles => true,
            },
        },
    }
}
