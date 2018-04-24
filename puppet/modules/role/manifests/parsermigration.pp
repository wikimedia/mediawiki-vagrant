# == Class: role::parsermigration
# The ParserMigration extension provides an interface for comparing
# article rendering with a new non-default version of the MediaWiki
# parser thus serving as a parser migration tool.
class role::parsermigration {
    mediawiki::extension { 'ParserMigration': }
}
