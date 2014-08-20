# == Class: role::geshi
# Configures SyntaxHighlight_GeSHi, an extension for syntax-highlighting
class role::geshi {
    mediawiki::extension { 'SyntaxHighlight_GeSHi': }
}
