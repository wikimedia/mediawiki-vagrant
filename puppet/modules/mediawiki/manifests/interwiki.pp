# == Define: mediawiki::interwiki
#
# Uses MediaWiki's maintenance scripts to add or remove
# (non-local) MediaWiki interwiki table entries.
#
# === Parameters
#
# [*url*]
#   Interwiki URL, with $1 for title.
#
# [*api*]
#   API URL of the remote wiki.
#
# [*prefix*]
#   Interwiki prefix.
#
# [*transclusion*]
#   Allow scary transclusion for this interwiki when
#   $wgEnableScaryTranscluding is on (default: no).
#
# [*db_name*]
#   Which wiki to add interwiki links for. Defaults to the main wiki.
#
# [*ensure*]
#   'present' to add the entry, 'absent' to remove it.
#   All parameters other than the prefix are optional for 'absent'.
#
define mediawiki::interwiki(
    $url,
    $api,
    $prefix       = $title,
    $transclusion = false,
    $db_name      = $::mediawiki::db_name,
    $ensure       = 'present',
) {
    include ::mediawiki

    validate_ensure($ensure)
    if ( $ensure == 'present' ) {
        $num_transclusion = $transclusion ? {
            true    => 1,
            default => 0,
        }
        mysql::sql { "add interwiki ${prefix} for ${db_name}":
            sql    => "REPLACE INTO ${db_name}.interwiki(iw_prefix, iw_url, iw_api, iw_wikiid, iw_local, iw_trans) VALUES ('${prefix}', '${url}', '${api}', '', 0, ${num_transclusion})",
            unless => "SELECT 1 FROM ${db_name}.interwiki WHERE iw_prefix = '${prefix}' AND iw_url = '${url}' AND iw_api = '${api}' AND iw_trans = '${num_transclusion}'",
        }
    } else {
        mysql::sql { "remove interwiki ${prefix} for ${db_name}":
            sql    => "DELETE FROM ${db_name}.interwiki WHERE iw_prefix = '${prefix}'",
            unless => "SELECT IF(count(*), 0, 1) FROM ${db_name}.interwiki WHERE iw_prefix = '${prefix}'",
        }
    }

    Mediawiki::Wiki <| |> -> MediaWiki::Interwiki <| |>
}
