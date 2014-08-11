# == Class: role::geshi
# Configures SyntaxHighlight_GeSHi, an extension for syntax-highlighting
class role::geshi {
    include role::mediawiki

    mediawiki::extension { 'SyntaxHighlight_GeSHi' : }
}
