# == Define: mediawiki::import::text
#
# Imports a string or text file into the wiki. This is the recommended method
# for importing version-controlled content such as documentation for vagrant
# roles; for importing current content from a wiki, see mediawiki::import::dump.
#
# Apart from cleaner diffs when put into version control, the main difference
# from mediawiki::import::dump is that mediawiki::import::text will update
# existing pages when necessary.
#
# Required parameters are page_title and exactly one of path or content.
#
# === Parameters
# [*page_title*]
#   Full title of the page where the text should be imported. Defaults to the
#   resource title. Should start with 'VagrantRole' to have it included in the
#   default index provided on Main_Page.
#
# [*source*]
#   Fully qualified path to the file to import.
#
# [*content*]
#   Page content as a string.
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
#   mediawiki::import::text { 'Main_Page':
#       content => template('mediawiki/mainpage.erb'),
#   }
#
define mediawiki::import::text(
    $page_title = $title,
    $source     = undef,
    $content    = undef,
    $db_name    = $::mediawiki::db_name,
    $wiki       = $::mediawiki::wiki_name,
) {
    if $source == undef and $content == undef  {
        fail('you must provide either "source" or "content"')
    }
    if $source != undef and $content != undef  {
        fail('"source" and "content" are mutually exclusive')
    }

    # Convert / to | in on disk path to make subpages possible. | is title
    # safe so there shouldn't be any way to end up with a collision.
    $safe_title = regsubst($page_title, '/', '|', 'G')
    $path = "${::mediawiki::page_dir}/wiki/${db_name}/${safe_title}"

    file { $path:
        source  => $source,
        content => $content,
        notify  => Exec["add page ${wiki}/${page_title}"],
    }

    mediawiki::maintenance { "add page ${wiki}/${page_title}":
        command     => "/usr/local/bin/mwscript edit.php --wiki=${db_name} --summary='Vagrant import' --no-rc '${page_title}' < '${path}'",
        refreshonly => true,
        require     => [
            Mediawiki::Wiki[$wiki],
            Exec["${db_name}_copy_LocalSettings"],
            Exec['update_all_databases'],
        ],
    }

    # Run sql before importing text
    Mysql::Sql <| |> -> Mediawiki::Import::Text <| |>
}
