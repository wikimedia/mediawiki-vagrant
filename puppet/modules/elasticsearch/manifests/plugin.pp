# == Define: elasticsearch::plugin
#
# An Elasticsearch plugin.
#
# === Parameters
#
# [*group*]
#   Group of the plugin.  Examples:
# org.wikimedia.search.highlighter
# elasticsearch
#
# [*name*]
#   Name of the plugin.  Examples:
# experimental-highlighter-elasticsearch-plugin
# elasticsearch-analysis-icu
#
# [*version*]
#   Version of the plugin.  Examples:
# 0.0.3
# 2.0.0
#
# === Example
#
# Install the icu analysis plugin:
#
#   elasticsearch::plugin { 'icu':
#     group   => 'elasticsearch',
#     name    => 'elasticsearch-analysis-icu',
#     version => '2.0.0',
#   }
#
define elasticsearch::plugin(
    $ensure  = present,
    $group   = 'elasticsearch',
    $name    = undef,
    $version = undef,
    $url     = undef,
) {
    $es_dir = '/usr/share/elasticsearch'
    $dirname = regsubst($name, '^elasticsearch-', '')
    $plugin_dir = "${es_dir}/plugins/${dirname}"
    $plugin_identifier = "${group}/${name}/${version}"
    $url_param = $url ? {
        undef   => '',
        default => "--url ${url}"
    }
    case $ensure {
        present: {
            # Install won't upgrade, so if the version if wrong we have to
            # remove it and reinstall.
            exec { "prune_es_plugin_${name}":
                command => "${es_dir}/bin/plugin --remove ${name}",
                onlyif  => "/usr/bin/test -d ${plugin_dir}",
                # lint:ignore:80chars
                unless  => "/usr/bin/test -f ${plugin_dir}/${name}-${version}.jar",
                # lint:endignore
                require => Package['elasticsearch'],
                notify  => Service['elasticsearch'],
            }
            exec { "install_es_plugin_${name}":
                # lint:ignore:80chars
                command => "${es_dir}/bin/plugin --install ${plugin_identifier} ${url_param}",
                # lint:endignore
                unless  => "/usr/bin/test -d ${plugin_dir}",
                require => [
                    Package['elasticsearch'],
                    Exec["prune_es_plugin_${name}"],
                ],
                notify  => Service['elasticsearch'],
            }
        }
        absent: {
            exec { "uninstall_es_plugin_${name}":
                command => "${es_dir}/bin/plugin --remove ${name}",
                onlyif  => "/usr/bin/test -d ${plugin_dir}",
                require => Package['elasticsearch'],
                notify  => Service['elasticsearch'],
            }
        }
        default: {
            fail("'ensure' may be 'present' or 'absent' (got: '${ensure}').")
        }
    }
}
