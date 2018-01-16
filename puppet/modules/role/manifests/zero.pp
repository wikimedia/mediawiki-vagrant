# == Class: role::zero
# Configures Zero for local use
class role::zero {
    include ::role::graph
    include ::role::jsonconfig
    include ::role::langwikis
    include ::role::mobilefrontend
    include ::role::parserfunctions
    include ::role::scribunto
    include ::role::thumb_on_404

    mediawiki::extension { 'ZeroBanner':
        priority => $::load_later, # Must be after JsonConfig & MobileFrontEnd
        settings => [
            '$wgMobileUrlTemplate = "%h0.m.%h1.%h2"',
            '$wgZeroSiteOverride = array( "wikipedia", "en" )',
            '$wgGroupPermissions["sysop"]["zero-edit"] = true',
            '$wgGroupPermissions["sysop"]["zero-script"] = true',
        ],
    }

    mediawiki::extension { 'ZeroPortal':
        priority => $::load_last, # Must be after ZeroBanner
        settings => [
            '$wgRawHtml = true',
        ],
    }
}
