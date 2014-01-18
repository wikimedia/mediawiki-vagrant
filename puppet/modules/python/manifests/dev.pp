# == Class: python::dev
#
# This includable class provides an easy way for classes to expresses a
# dependency on python-dev without causing duplicate definition errors.
#
class python::dev {
    package { 'python-dev': }
}
