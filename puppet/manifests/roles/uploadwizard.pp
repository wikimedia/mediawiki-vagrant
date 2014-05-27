# == Class: role::uploadwizard
# Configures a MediaWiki instance with [UploadWizard][1], a JavaScript-driven
# wizard interface for uploading multiple files.
#
# [1] https://www.mediawiki.org/wiki/Extension:UploadWizard
class role::uploadwizard {
    include role::mediawiki
    include role::eventlogging
    include role::multimedia
    include role::codeeditor

    # API smoke test dependencies
    include python::pil
    include packages::poster
    include packages::wikitools
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
