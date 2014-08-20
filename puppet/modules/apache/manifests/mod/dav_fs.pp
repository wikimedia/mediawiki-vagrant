# == Class: apache::mod::dav_fs
#
class apache::mod::dav_fs {
    apache::mod_conf { 'dav_fs': }
}
