# == Class: apache::mod::version
#
class apache::mod::version {
    if versioncmp($::lsbdistrelease, '13.10') < 0 {
        apache::mod_conf { 'version': }
    }
}
