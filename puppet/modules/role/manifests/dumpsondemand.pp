# == Class: role::dumpsondemand
# The DumpsOnDemand extension allows users to request and download dumps on a special page on the
# wiki.
class role::dumpsondemand {
    mediawiki::extension { 'DumpsOnDemand':
        settings => [
            '$wgGroupPermissions["bureaucrat"]["dumpsondemand-limit-exempt"] = true;',
            '$wgGroupPermissions["user"]["dumpsondemand"] = true;',
            '$wgGroupPermissions["user"]["dumprequestlog"] = true;'
        ]
    }
}
