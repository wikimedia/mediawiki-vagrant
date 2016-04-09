# == Class: role::mobileapp
# Configures MobileApp, which produces CSS files and hooks
# for the Wikimedia Android & iOS Mobile apps
class role::mobileapp {
    include ::role::mobilefrontend
    include ::role::cite

    mediawiki::extension { 'MobileApp':
        require => Mediawiki::Extension['MobileFrontend'],
    }
}
