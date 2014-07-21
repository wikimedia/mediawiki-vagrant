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
#   same name. If you need anything fancy, create a module instead.
#
# *Note*:: please add new classes in alphabetical order to make finding
#   things easier.
#

class packages::djvulibre_bin {
    package { 'djvulibre-bin': }
}

class packages::drush {
    package { 'drush': }
}

class packages::exiv2 {
    package { 'exiv2': }
}

class packages::ffmpeg2theora {
    package { 'ffmpeg2theora': }
}

class packages::fonts_dejavu {
    package { 'fonts-dejavu': }
}

class packages::fss {
    package { 'php5-fss': }
}

class packages::ghostscript {
    package { 'ghostscript': }
}

class packages::imagemagick {
    package { 'imagemagick': }
}

class packages::java {
    package { 'openjdk-7-jdk': }
}

class packages::jq {
    package { 'jq': }
}

class packages::jsduck {
    package { 'jsduck':
        ensure   => '4.10.4',
        provider => 'gem',
    }
}

class packages::libav_tools {
    package { 'libav-tools': }
}

class packages::libtiff_tools {
    package { 'libtiff-tools': }
}

class packages::mediawiki_math {
    package { 'mediawiki-math': }
}

class packages::netpbm {
    package { 'netpbm': }
}

class packages::ocaml_native_compilers {
    package { 'ocaml-native-compilers': }
}

class packages::php5_tidy {
    package { 'php5-tidy': }
}

class packages::php_luasandbox {
    package { 'php-luasandbox': }
}

class packages::poppler_utils {
    package { 'poppler-utils': }
}

class packages::python_imaging {
    package { 'python-imaging': }
}

class packages::python_nose {
    package { 'python-nose': }
}

class packages::python_poster {
    package { 'python-poster': }
}

class packages::python_wikitools {
    package { 'wikitools':
        ensure   => '1.1',
        provider => 'pip',
    }
}

class packages::rsyslog {
    package { 'rsyslog': }
}

class packages::unzip {
    package { 'unzip': }
}

class packages::wbritish_small {
    package { 'wbritish-small': }
}

class packages::wikidiff2 {
    package { 'php-wikidiff2': }
}
