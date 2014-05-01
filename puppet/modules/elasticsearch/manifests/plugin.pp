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
    $group   = undef,
    $name    = undef,
    $version = undef,
    $url     = undef,
) {
    $esDir = '/usr/share/elasticsearch'
    $dirname = regsubst($name, '^elasticsearch-', '')
    $pluginDir = "${esDir}/plugins/${dirname}"
    $pluginIdentifier = "${group}/${name}/${version}"
    $urlParam = $url ? {
        undef   => '',
        default => "--url ${url}"
    }
    case $ensure {
        present: {
            # Install won't upgrade, so if the version if wrong we have to
            # remove it and reinstall.
            exec { "Remove bad version of plugin ${name}":
                command => "${esDir}/bin/plugin --remove ${name}",
                onlyif  => "test -d ${pluginDir}",
                unless  => "test -f ${pluginDir}/${name}-${version}.jar",
                require => Package['elasticsearch'],
                notify  => Service['elasticsearch'],
            }
            exec { "Install elasticsearch plugin ${name}":
                command => "${esDir}/bin/plugin --install ${pluginIdentifier} ${urlParam}",
                unless  => "test -d ${pluginDir}",
                require => [
                    Package['elasticsearch'],
                    Exec["Remove bad version of plugin ${name}"],
                ],
                notify  => Service['elasticsearch'],
            }
        }
        absent: {
            exec { "Uninstall elasticsearch plug ${name}":
                command => "${esDir}/bin/plugin --remove ${name}",
                onlyif  => "test -d ${pluginDir}",
                require => Package['elasticsearch'],
                notify  => Service['elasticsearch'],
            }
        }
        default: {
            fail("'ensure' may be 'present' or 'absent' (got: '${ensure}').")
        }
    }
}
