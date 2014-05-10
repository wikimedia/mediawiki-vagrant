# == Class: python::pil
#
# The Python Imaging Library (PIL) adds image processing capabilities to your
# Python interpreter. This library supports many file formats, and provides
# powerful image processing and graphics capabilities.
#
class python::pil {
    include ::python::dev

    package { 'zlib1g-dev': }
    # needed for ConfirmEdit's FancyCaptcha
    package { 'libfreetype6-dev': }

    # Workaround for 'pip install pil' failing to find libz.so and thus
    # installing without zlib support. See <http://goo.gl/eWJc24>.
    file { '/usr/lib/libz.so':
        ensure  => link,
        target  => "/usr/lib/${::hardwaremodel}-linux-gnu/libz.so",
        require => Package['zlib1g-dev'],
    }

    # Workaround for 'pip install pil' failing to find libfreetype.so and
    # thus installing without freetype support. See <http://goo.gl/eWJc24>.
    file { '/usr/lib/libfreetype.so':
        ensure  => link,
        target  => "/usr/lib/${::hardwaremodel}-linux-gnu/libfreetype.so",
        require => Package['libfreetype6-dev'],
    }

    package { 'PIL':
        ensure   => '1.1.7',
        provider => 'pip',
        require  => [
            Package['python-dev', 'zlib1g-dev', 'libfreetype6-dev'],
            File['/usr/lib/libz.so', '/usr/lib/libfreetype.so'],
        ],
    }
}
