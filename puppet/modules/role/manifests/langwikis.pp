# == Class: role::langiwikis
# Creates a set of wikis for testing various languages.
# The list is configured by role::langwikis::langwiki_list.
class role::langwikis(
    $langwiki_list
) {
    create_resources(mediawiki::langwiki, $langwiki_list)
}
