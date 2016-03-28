# == Class: role::torblock
# Configures TorBlock, a MediaWiki extension that allows blocking
# access to the wiki through Tor
class role::torblock {
    mediawiki::extension { 'TorBlock': }
}
