# == Class: role::unlinkedwikibase
# The UnlinkedWikibase extension provides a Lua module
# for fetching data from Wikidata or another Wikibase wiki.
# https://www.mediawiki.org/wiki/Extension:UnlinkedWikibase
class role::unlinkedwikibase {
    mediawiki::extension { 'UnlinkedWikibase': }
}
