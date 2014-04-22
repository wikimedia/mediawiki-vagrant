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

class packages::php5_tidy {
    package { 'php5-tidy': }
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

class packages::ffmpeg {
    package { 'ffmpeg': }
}

class packages::ffmpeg2theora {
    package { 'ffmpeg2theora': }
}

class packages::java {
    package { 'openjdk-7-jdk': }
}

class packages::wikitools {
    package { 'wikitools':
        ensure   => '1.1',
        provider => 'pip',
    }
}

class packages::poster {
    package { 'poster':
        ensure   => '0.8.0',
        provider => 'pip',
    }
}

class packages::nose {
    package { 'nose':
        ensure   => '1.3.0',
        provider => 'pip',
    }
}

class packages::jsduck {
    package { 'jsduck':
        ensure   => '4.10.4',
        provider => 'gem',
    }
}

class packages::wikidiff2 {
    package { 'php-wikidiff2': }
}

class packages::jq {
    package { 'jq': }
}
