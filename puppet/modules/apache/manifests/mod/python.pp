# == Class: apache::mod::python
#
class apache::mod::python {
    package { 'libapache2-mod-python': }
    apache::mod_conf { 'python':
        require => Package['libapache2-mod-python'],
    }
}
