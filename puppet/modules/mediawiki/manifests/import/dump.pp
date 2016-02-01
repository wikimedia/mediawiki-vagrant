# == Define: mediawiki::import::dump
#
# Imports an xml dump into the wiki. This is the recommended method for
# importing "live" content from a wiki; for importing content that should live
# in the puppet repository, see mediawiki::import::text.
#
# === Parameters
# [*xml_dump*]
#   Fully qualified path to a dump file to import.
#
# [*dump_sentinel_page*]
#   Name of unique page in the wiki created by the dump. As long as this page
#   is not present in the wiki we will keep trying the import.
#
# [*db_name*]
#   Wiki database to import page into. The default will import into the
#   primary wiki.
#
# [*wiki*]
#   Wiki to import page into. The default will import into the primary wiki.
#
# == Usage
#
#   mediawiki::import::dump { 'labs_privacy':
#       xml_dump           => '/vagrant/labs_privacy_policy.xml',
#       dump_sentinel_page => 'Testwiki:Privacy_policy',
#   }
#
define mediawiki::import::dump(
    $xml_dump,
    $dump_sentinel_page,
    $db_name             = $::mediawiki::db_name,
    $wiki                = $::mediawiki::wiki_name,
) {
    require ::mediawiki

    mediawiki::maintenance { "import_dump_${title}":
        command => "/usr/local/bin/mwscript importDump.php --wiki=${db_name} ${xml_dump}",
        unless  => "/usr/local/bin/mwscript pageExists.php --wiki=${db_name} ${dump_sentinel_page}",
        require => Mediawiki::Wiki[$wiki],
    }

    MediaWiki::Extension <| |> -> Mediawiki::Import::Dump <| |>
    Mysql::Sql <| |> -> Mediawiki::Import::Dump <| |>
}
