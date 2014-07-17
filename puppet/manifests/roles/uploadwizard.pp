# == Class: role::uploadwizard
# Configures a MediaWiki instance with
# UploadWizard[https://www.mediawiki.org/wiki/Extension:UploadWizard]
# a JavaScript-driven wizard interface for uploading multiple files.
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

    $uw_common_settings = {
        wgEnableUploads       => true,
        wgUseImageMagick      => true,
        wgUploadNavigationUrl => '/wiki/Special:UploadWizard',
        wgApiFrameOptions     => 'SAMEORIGIN',
        wgUploadWizardConfig  => {
            altUploadForm       => 'Special:Upload',
            autoCategory        => 'Uploaded with UploadWizard',
            enableChunked       => 'opt-in',
            enableFormData      => true,
            enableMultipleFiles => true,
        },
    }

    mediawiki::extension { 'Campaigns': }

    mediawiki::extension { 'UploadWizard':
        require  => Package['imagemagick'],
        settings => $uw_common_settings,
    }
}

# == Define: ::role::uploadwizard::multiwiki
# Configure a multiwiki instance with UploadWizard.
define role::uploadwizard::multiwiki {
    include packages::imagemagick

    multiwiki::extension { "${title}:Campaigns": }

    multiwiki::extension { "${title}:UploadWizard":
        require  => Package['imagemagick'],
        settings => $::role::uploadwizard::uw_common_settings,
    }
}
