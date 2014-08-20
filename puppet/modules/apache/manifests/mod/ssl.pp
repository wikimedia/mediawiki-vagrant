# == Class: apache::mod::ssl
#
class apache::mod::ssl {
    apache::mod_conf { 'ssl': }
}
