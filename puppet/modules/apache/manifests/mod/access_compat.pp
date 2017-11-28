# == Class: apache::mod::access_compat
#
class apache::mod::access_compat {
    if versioncmp($::lsbdistrelease, '13.10') >= 0 {
        apache::mod_conf { 'access_compat': }
    }
}
