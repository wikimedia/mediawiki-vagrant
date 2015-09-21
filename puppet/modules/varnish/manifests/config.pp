# == Define: varnish::config
#
# Sets up a new Varnish config file.
#
# === Parameters
#
# [*source*]
#   VCL file source.
#
# [*content*]
#   VCL file content.
#
# [*order*]
#   Order in which Varnish will apply your configuration (0-99).
#   Default: 60 (apply just after default VCL).
#
# === Examples
#
#   varnish::config { 'thumbor':
#       source => 'puppet:///modules/thumbor/varnish.vcl',
#       order  => 99,
#   }
#
define varnish::config(
    $source = undef,
    $content = undef,
    $order = 60,
) {
    include ::varnish

    $i = sprintf('%02d', $order)
    $path = "${::varnish::confd}/${i}-${title}.vcl"

    file { $path:
        source  => $source,
        content => $content,
        mode    => '0644',
        notify  => Service['varnish'],
    }

    file_line { "${::varnish::conf}:${title}":
        line    => "include \"${path}\";",
        path    => $::varnish::conf,
        match   => "${::varnish::confd}/[0-9]+-${title}.vcl",
        require => File[$path],
        notify  => Exec['varnish_sort_confd'],
    }
}
