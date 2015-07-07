# == Class: role::testwiki
# Adds another wiki, available at
# test.wiki.local.wmftest.net:<port>

class role::testwiki() {
    require ::role::mediawiki
    mediawiki::wiki { 'test': }
}
