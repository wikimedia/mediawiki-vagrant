# == Class: apache::mod::authz_svn
#
class apache::mod::authz_svn {
    package { 'libapache2-svn': }
    apache::mod_conf { 'authz_svn':
        require => Package['libapache2-svn'],
    }
}
