# == Class: role::geshi
# Configures SyntaxHighlight_GeSHi, an extension for syntax-highlighting
#
# *deprecated* Use ::role::syntaxhighlight
class role::geshi {
    include ::role::syntaxhighlight
}
