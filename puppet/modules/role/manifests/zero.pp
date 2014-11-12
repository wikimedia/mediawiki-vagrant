# == Class: role::zero
# Configures Zero for local use
class role::zero {
    include ::role::mobilefrontend
    include ::role::jsonconfig
    include ::role::thumb_on_404
    include ::role::scribunto
    include ::role::graph
    include ::role::parserfunctions

    mediawiki::extension { 'ZeroBanner':
        priority => $::LOAD_LATER, # Must be after JsonConfig & MobileFrontEnd
        settings => [
            '$wgMobileUrlTemplate = "%h0.m.%h1.%h2"',
            '$wgZeroSiteOverride = array( "wikipedia", "en" )',
            '$wgGroupPermissions["sysop"]["zero-edit"] = true',
            '$wgGroupPermissions["sysop"]["zero-script"] = true',
        ],
    }

    mediawiki::extension { 'ZeroPortal':
        priority => $::LOAD_LAST, # Must be after ZeroBanner
        settings => [
            '$wgRawHtml = true',
        ],
    }

    mediawiki::wiki { 'es': }
    mediawiki::wiki { 'ru': }
    mediawiki::wiki { 'zh': }
}
