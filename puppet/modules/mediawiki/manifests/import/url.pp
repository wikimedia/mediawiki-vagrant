# == Define: mediawiki::import::url
#
# Imports a MediaWiki article from a given URL into the wiki. Intended for
# test articles where fine control of the content is not important and
# adding it to the repository would be a waste of space. Changes to the
# remote article will not be reflected (unless the local one is manually
# deleted).
#
# If you import from a Wikimedia project, you'll probably want to
# enable the tidy role, otherwise templates get all messed up.
#
# See also mediawiki::import::text (for importing manually defined,
# version-controlled content) and mediawiki::import::dump (for importing
# many pages).
#
# None of the parameters are required.
#
# === Parameters
# [*page_title*]
#   Full title of the page where the text should be imported. Defaults to the
#   resource title.
#
# [*scriptPath*]
#   Script path of the wiki to import from (as in $wgScriptPath).
#   Will default to the English Wikipedia for convenience. Single quotes must
#   be URL-escaped (although hopefully you don't have those in your script path).
#
# [*expanded*]
#   When true (which is the default), template expansion is done on the remote
#   wiki. This is usually preferable as something like an enwiki infobox would
#   take minutes to process on a VM and require a bunch of extensions which are
#   probably not installed.
#
# [*query*]
#   Additional query parameters when fetching the contents from the remote wiki.
#   Can be used for example to specify an oldid or override the title (which
#   will default to the resource name).
#
# [*db_name*]
#   Wiki database to import page into. The default will import into the
#   primary wiki.
#
# [*wiki*]
#   Wiki to import page into. The default will import into the primary wiki.
#
# === Usage
#
#   mediawiki::import::url { 'Main_Page': }
#
define mediawiki::import::url(
    $page_title  = $title,
    $script_path = 'https://en.wikipedia.org/w/index.php',
    $expanded    = true,
    $query       = {},
    $db_name     = $::mediawiki::db_name,
    $wiki        = $::mediawiki::wiki_name,
) {
    $expand_param = $expanded ? {
        true  => 'expand',
        false => undef,
    }
    $base_query = {
        title => $title,
        action => 'raw',
        templates => $expand_param,
    }
    $query_string = make_url(merge($base_query, $query))
    $safe_title = shellescape($page_title)

    $curl_command = "/usr/bin/curl --fail --silent '${script_path}?${query_string}'"
    $edit_command = "/usr/local/bin/mwscript edit.php --wiki=${db_name} --summary='Vagrant import' --no-rc ${safe_title}"

    mediawiki::maintenance { "import content from ${page_title}":
        # there is no way to abort a pipe so a curl error will result in an
        # empty article being created (which will afterwards trigger the
        # unless branch). Fail the command in that case to at least give
        # the user a fighting chance to figure out what happened.
        command => "set -o pipefail; ${curl_command} | ${edit_command}",
        unless  => "/usr/local/bin/mwscript pageExists.php --wiki=${db_name} ${safe_title}",
        # Parsing large articles can be slow, even with expanded => true
        timeout => 1800,
        require => [
            Mediawiki::Wiki[$wiki],
            Exec["${db_name}_copy_LocalSettings"],
            Exec['update_all_databases'],
        ],
    }

    # Run sql before importing text
    Mysql::Sql <| |> -> Mediawiki::Import::Text <| |>
}
