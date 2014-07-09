# == Define: apache::site_conf
#
# This resource type represents a collection of Apache configuration
# directives scoped to a particular site.
#
# === Parameters
#
# [*site*]
#   Name of site to configure.
#
# [*content*]
#   String containing Apache configuration directives. Either this or
#   'source' must be specified. Undefined by default.
#
# [*source*]
#   Path to file containing Apache configuration directives. Either this
#   or 'content' must be specified. Undefined by default.
#
# === Example
#
# Configure the default site to use UTF-8 as the default charset:
#
#   apache::site_conf { 'default_charset':
#     site    => 'default',
#     content => 'AddDefaultCharset utf-8',
#   }
#
define apache::site_conf(
    $site,
    $ensure   = present,
    $priority = 50,
    $content  = undef,
    $source   = undef,
) {
    include ::apache

    $site_safe  = regsubst($site, '[\W_]', '-', 'G')
    $title_safe = regsubst($title, '[\W_]', '-', 'G')
    $conf_file  = sprintf('%02d-%s.conf', $priority, $title_safe)

    file { "/etc/apache2/site-confs/${site_safe}/${conf_file}":
        ensure  => $ensure,
        content => $content,
        source  => $source,
        notify  => Service['apache2'],
    }
}
