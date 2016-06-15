# == Define: elasticsearch::plugin
#
# An Elasticsearch plugin.
#
# === Parameters
#
# [*title*]
#   Name of the plugin (artifact).  Examples:
# experimental-highlighter-elasticsearch-plugin
# elasticsearch-analysis-icu
#
# [*group*]
#   Group of the plugin.  Examples:
# org.wikimedia.search.highlighter
# elasticsearch
#
# [*esname*]
#   Name of the plugin seen by elasticsearch
#
# [*core*]
#   Set to true for plugins distributed by elastic.co
#
# === Example
#
# Install the icu analysis plugin:
#
#   elasticsearch::plugin { 'analysis-icu':
#       core => true,
#   }
# Or a specific version of the highlighter plugin:
#   elasticsearch::plugin { 'experimental-highlighter-elasticsearch-plugin':
#       ensure => '2.3.3.1',
#       group  => 'org.wikimedia.search.highlighter',
#       esname => 'experimental-highlighter',
#   }
#
define elasticsearch::plugin(
    $ensure = present,
    $group  = undef,
    $esname = undef,
    $url    = undef,
    $core   = false,
) {
    $es_dir = '/usr/share/elasticsearch'
    $dirname = $esname ? {
        undef   => regsubst($title, '^elasticsearch-', ''),
        default => $esname
    }

    # FIXME: this might not work well if elastic version is set to 'latest'
    $version = $ensure ? {
        present => $elasticsearch::version,
        absent  => $elasticsearch::version,
        undef   => $elasticsearch::version,
        default => $ensure
    }

    $_esversion = $elasticsearch::version

    $plugin_dir = "${es_dir}/plugins/${dirname}"
    # Core plugins are part of elastic realease process thus no version nor
    # group should be provided.
    $plugin_identifier = $core ? {
        true  => $title,
        false => "${group}/${title}/${version}"
    }

    $url_param = $url ? {
        undef   => '',
        default => "--url ${url}"
    }
    case $ensure {
        present: {
            exec { "prune_es_plugin_${title}":
                command => "${es_dir}/bin/plugin remove ${dirname}",
                unless  => "egrep -s ^version=${version} ${plugin_dir}/plugin-descriptor.properties",
                require => Package['elasticsearch'],
                notify  => Service['elasticsearch'],
            }
            # We need to delete all old plugins before trying to install a new
            # one, "bin/plugin install" will simply fail if an unsupported one is found
            # in the plugins directory
            exec { "cleanup_old_plugins_${title}":
                command => "find ${es_dir}/plugins -mindepth 1 -maxdepth 1 -type d '!' \
                           '(' -exec test -e '{}/plugin-descriptor.properties' ';' -a \
                           -exec egrep -q \"(^elasticsearch.version=${_esversion}|^site=true)\" \
                           {}/plugin-descriptor.properties \\; ')' \
                           -exec sh -c '${es_dir}/bin/plugin remove `basename {}`' ';'",
                onlyif  => "find ${es_dir}/plugins -mindepth 1 -maxdepth 1 -type d '!' \
                           '(' -exec test -e '{}/plugin-descriptor.properties' ';' -a \
                           -exec egrep -q \"(^elasticsearch.version=${_esversion}|^site=true)\" \
                           {}/plugin-descriptor.properties \\; ')' -print | grep .",
                require => Package['elasticsearch'],
                notify  => Service['elasticsearch'],
            }
            exec { "install_es_plugin_${title}":
                command => "${es_dir}/bin/plugin install ${plugin_identifier} ${url_param}",
                unless  => "egrep -s ^version=${version} ${plugin_dir}/plugin-descriptor.properties",
                require => [
                    Package['elasticsearch'],
                    Exec["prune_es_plugin_${title}"],
                    Exec["cleanup_old_plugins_${title}"],
                ],
                notify  => Service['elasticsearch'],
            }
        }
        absent: {
            exec { "uninstall_es_plugin_${title}":
                command => "${es_dir}/bin/plugin remove ${title}",
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
