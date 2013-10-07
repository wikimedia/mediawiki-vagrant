# == Package dependencies for roles
#
# Each class in this module corresponds to a package required by some
# role. The advantage of this layout compared to declaring package
# resources in roles is that a class may be included multiple times,
# whereas a package resource can only be declared in one place. By using
# class proxies for package dependencies, roles with overlapping
# dependencies can be used in tandem without running afoul of Puppet's
# prohibition on duplicate definitions.
#
# *Note*:: each class in this file must correspond to a package of the
#   same name. The package must be declared with no parameters. If you
#   need to do anything fancier, create a module instead.
#

class packages::imagemagick {
    package { 'imagemagick': }
}

class packages::ghostscript {
    package { 'ghostscript': }
}

class packages::poppler_utils {
    package { 'poppler-utils': }
}

class packages::rsyslog {
    package { 'rsyslog': }
}

class packages::php_luasandbox {
    package { 'php-luasandbox': }
}

class packages::djvulibre_bin {
    package { 'djvulibre-bin': }
}

class packages::netpbm {
    package { 'netpbm': }
}

class packages::mediawiki_math {
    package { 'mediawiki-math': }
}

class packages::ocaml_native_compilers {
    package { 'ocaml-native-compilers': }
}

class packages::elasticsearch {
    package { 'elasticsearch': }
}
