# == Class: role::globalusage
# Configures a MediaWiki instance with
# GlobalUsage[https://www.mediawiki.org/wiki/Extension:GlobalUsage]
class role::globalusage {
    mediawiki::extension { 'GlobalUsage': }
}
