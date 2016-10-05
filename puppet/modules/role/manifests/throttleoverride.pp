# == Class: role::throttleoverride
# Installs the [ThrottleOverride][1] extension which allows privileged users
# to override certain rate limits for temporary or indefinite amounts of time.
#
# [1] https://www.mediawiki.org/wiki/Extension:ThrottleOverride
class role::throttleoverride {
    mediawiki::extension { 'ThrottleOverride':
        needs_update => true,
        settings     => [
            '$wgGroupPermissions["sysop"]["throttleoverride"] = true;',
        ],
    }
}
