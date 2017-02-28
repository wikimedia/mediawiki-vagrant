# == Define: elasticsearch::plugin
#
# An Elasticsearch plugin.
#
# === Parameters
#
# [*title*]
#   Name of the plugin (artifact).  Examples:
# experimental-highlighter-elasticsearch-plugin
# analysis-icu
#
# [*group*]
#   Group of the plugin.  Examples:
# org.wikimedia.search.highlighter
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
#
# Or the highlighter plugin:
#   elasticsearch::plugin { 'experimental-highlighter-elasticsearch-plugin':
#       group  => 'org.wikimedia.search.highlighter',
#       esname => 'experimental-highlighter',
#   }
#
define elasticsearch::plugin(
    $ensure = present,
    $group  = undef,
    $esname = $title,
    $core   = false,
) {
    # Core plugins are part of elastic realease process thus no additional
    # information should be provided. External plugins (such as those released
    # by wikimedia) provide the group and artifact ids. the mwv-elasticsearch-plugin
    # script will convert this into a url to request from maven central
    $plugin_identifier = $core ? {
        true  => '',
        false => "${group} ${title}"
    }

    case $ensure {
        present: {
            exec { "install_es_plugin_${title}":
                command => "/usr/local/bin/mwv-elasticsearch-plugin install ${esname} ${plugin_identifier}",
                unless  => "/usr/local/bin/mwv-elasticsearch-plugin check ${esname}",
                require => [
                    Package['elasticsearch'],
                    File['/usr/local/bin/mwv-elasticsearch-plugin']
                ],
                notify  => Service['elasticsearch'],
            }
        }
        absent: {
            exec { "uninstall_es_plugin_${title}":
                command => "/usr/local/bin/mwv-elasticsearch-plugin uninstall ${esname}",
                onlyif  => "/usr/bin/test -d /usr/share/elasticsearch/plugins/${esname}",
                require => [
                    Package['elasticsearch'],
                    File['/usr/local/bin/mwv-elasticsearch-plugin'],
                ],
                notify  => Service['elasticsearch'],
            }
        }
        default: {
            fail("'ensure' may be 'present' or 'absent' (got: '${ensure}').")
        }
    }
}
