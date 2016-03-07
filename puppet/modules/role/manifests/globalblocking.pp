# == Class: role::globalblocking
# Configures a MediaWiki instance with
# GlobalBlocking[https://www.mediawiki.org/wiki/Extension:GlobalBlocking]
class role::globalblocking {
    mediawiki::extension { 'GlobalBlocking': }
}
