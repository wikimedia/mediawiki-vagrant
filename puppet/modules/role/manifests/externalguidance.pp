# == Class: role::externalguidance
#
# Installs the ExternalGuidance[1] extension which shows guidance messages
# to users visiting pages through a 3rd-party page translator.
#
# [1] https://www.mediawiki.org/wiki/Extension:ExternalGuidance
#
class role::externalguidance {
    include ::role::mobilefrontend
    include ::role::uls

    mediawiki::extension { 'ExternalGuidance':
        needs_update => true,
        settings     => {
            wgExternalGuidanceSimulate    => true,
            wgExternalGuidanceMTReferrers => [
                    'translate.google.com',
                    'translate.googleusercontent.com'
                ]

        }
    }
}
