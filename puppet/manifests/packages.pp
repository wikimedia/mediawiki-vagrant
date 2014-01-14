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

class packages::ffmpeg {
    package { 'ffmpeg': }
}

class packages::ffmpeg2theora {
    package { 'ffmpeg2theora': }
}

class packages::java {
    package { 'openjdk-7-jdk': }
}

class packages::python_dev {
    package { 'python-dev': }
}

class packages::zlib1g_dev {
    package { 'zlib1g-dev': }
}

class packages::wikitools {
    package { 'wikitools':
        ensure   => '1.1',
        provider => 'pip',
    }
}

class packages::poster {
    package { 'poster':
        ensure   => '0.8',
        provider => 'pip',
    }
}

class packages::pil {
    include packages::zlib1g_dev
    include packages::python_dev

    # Workaround for 'pip install pil' failing to find libz.so and thus
    # installing without zlib support. See <http://goo.gl/eWJc24>.
    file { '/usr/lib/libz.so':
        ensure => link,
        target => "/usr/lib/${::hardwaremodel}}-linux-gnu/libz.so",
        before => Package['pil'],
    }

    package { 'pil':
        ensure   => '1.1.7',
        provider => 'pip',
        require  => Package['python-dev', 'zlib1g-dev'],
    }
}
