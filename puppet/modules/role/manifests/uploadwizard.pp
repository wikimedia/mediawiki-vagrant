# == Class: role::uploadwizard
# Configures a MediaWiki instance with
# UploadWizard[https://www.mediawiki.org/wiki/Extension:UploadWizard]
# a JavaScript-driven wizard interface for uploading multiple files.
class role::uploadwizard {
    include ::wikitools
    include ::role::eventlogging
    include ::role::multimedia
    include ::role::codeeditor

    # API smoke test dependencies
    require_package('imagemagick')
    require_package('python-imaging')
    require_package('python-poster')

    mediawiki::extension { 'Campaigns': }

    mediawiki::extension { 'UploadWizard':
        require  => Package['imagemagick'],
        settings => {
            wgAllowCopyUploads    => true,
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
                flickrApiKey        => 'b22fa793bf3189dadcd6fe2837843534',
            },
        },
    }

    mediawiki::settings { 'UploadWizard permissions':
        values => [
            '$wgGroupPermissions["*"]["upload"] = true;',
            '$wgGroupPermissions["*"]["upload_by_url"] = true;',
        ],
    }
}
