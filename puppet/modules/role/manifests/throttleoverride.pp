# == Class: role::throttleoverride
# Installs the ThrottleOverride[https://www.mediawiki.org/wiki/Extension:ThrottleOverride]
# extension which allows privileged users to override certain rate
# limits for temporary or indefinite amounts of time.
#
class role::throttleoverride {
    mediawiki::extension { 'ThrottleOverride':
        needs_update => true,
        settings     => [
            '$wgGroupPermissions["sysop"]["throttleoverride"] = true;',
        ],
    }
}
