# == Define: apache::conf
#
# This resource type represents a collection of Apache configuration
# directives. Directives may be global or scoped to a particular site.
#
# === Parameters
#
# [*content*]
#   String containing Apache configuration directives. Either this or
#   'source' must be specified. Undefined by default.
#
# [*source*]
#   Path to file containing Apache configuration directives. Either this
#   or 'content' must be specified. Undefined by default.
#
# [*site*]
#   If set, the configuration will be scoped to a particular Apache
#   site, specified by name. If undefined (the default), configuration
#   will apply globally.
#
# === Example
#
# Configure the default site to use UTF-8 as the default charset:
#
#   apache::conf { 'default charset':
#     site    => 'default',
#     content => 'AddDefaultCharset utf-8',
#   }
#
define apache::conf(
    $ensure   = present,
    $site     = undef,
    $content  = undef,
    $source   = undef,
) {
    include ::apache

    if versioncmp($::lsbdistrelease, '14') > 0 {
        $global_config_dir = '/etc/apache2/conf-available'
        $config_extension = '.conf'
    } else {
        $global_config_dir = '/etc/apache2/conf.d'
        $config_extension = ''
    }

    $config_dir = $site ? {
        undef   => $global_config_dir,
        default => "/etc/apache2/site.d/${site}"
    }

    $config_file = inline_template('<%= @title.gsub(/\W/, "-") %>')

    file { "${config_dir}/${config_file}${config_extension}":
        ensure  => $ensure,
        content => $content,
        source  => $source,
        require => Package['apache2'],
        notify  => [ Exec['refresh_conf_symlinks'], Service['apache2'] ],
    }
}
