# == Class: role::thumbor
# Installs a Thumbor instance
#
class role::thumbor (
) {
    require ::role::varnish
    require ::role::statsd
    require ::role::memcached
    require ::role::pagedtiffhandler
    require ::role::pdfhandler
    require ::role::poolcounter
    require ::role::swift
    require ::role::three_d
    require ::role::timedmediahandler
    require ::role::multimedia
    require ::role::vipsscaler
    require ::role::wikimediamaintenance
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
    include ::apache::mod::headers
    include ::thumbor

    # This will generate a list of ports starting at 8889, with
    # as many ports as there are CPUs on the machine.
    $ports = sequence_array(8889, $::processorcount)

# Switch the haproxy section out for this to have nginx front thumbor
#    file { '/etc/nginx/prometheus.lua':
#        ensure => present,
#        source => 'puppet:///modules/role/thumbor/prometheus.lua',
#    }
#
#    nginx::site { 'thumbor':
#        content => template('role/thumbor/nginx.conf.erb'),
#        notify  => Service['nginx'],
#        require => File['/etc/nginx/prometheus.lua'],
#    }

    haproxy::site { 'thumbor':
        content => template('role/thumbor/haproxy.cfg.erb'),
    }

    mediawiki::settings { 'thumbor-repo':
        values   => template('role/thumbor/local_repo.php.erb'),
        # Needs to be higher priority that swift for the local repo override
        priority => 20,
    }

    mediawiki::settings { 'thumbor':
        values => {
            'wgUploadThumbnailRenderMethod' => 'http',
            'wgTiffUseTiffinfo'             => false,
            'wgIgnoreImageErrors'           => true,
            'wgDjvuRenderer'                => '/usr/bin/ddjvu',
            'wgDjvuDump'                    => '/usr/bin/djvudump',
            'wgDjvuToXML'                   => '/usr/bin/djvutoxml',
            'wgDjvuTxt'                     => '/usr/bin/djvutxt',
            'wgDjvuPostProcessor'           => '/usr/bin/ppmtojpeg',
            'wgDjvuOutputExtension'         => 'jpg',
            'wgFileExtensions'              => [
                'apng',
                'png',
                'gif',
                'jpg',
                'jpe',
                'jpeg',
                'xcf',
                'svg',
                'ogv',
                'webm',
                'djvu',
                'pdf',
                'stl',
                'tiff',
                'tif',
                'webp',
            ],
        },
    }
}
