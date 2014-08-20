# == Class: role::parserfunctions
# The ParserFunctions extension enhances the wikitext parser with
# helpful functions, mostly related to logic and string-handling.
class role::parserfunctions {
    mediawiki::extension { 'ParserFunctions': }
}
