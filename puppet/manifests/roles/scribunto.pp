# == Class: role::scribunto
# Configures Scribunto, an extension for embedding scripting languages
# in MediaWiki.
class role::scribunto {
    include role::mediawiki
    include role::codeeditor
    include role::geshi

    include packages::php_luasandbox
    include packages::lua5_1

    mediawiki::extension { 'Scribunto':
        settings => {
            wgScribuntoDefaultEngine => 'luastandalone',
            wgScribuntoUseGeSHi      => true,
            wgScribuntoUseCodeEditor => true,
        },
        notify   => Service['apache2'],
        require  => [
            Mediawiki::Extension['CodeEditor'],
            Mediawiki::Extension['SyntaxHighlight_GeSHi'],
            Package['php-luasandbox', 'lua5.1'],
        ],
    }
}
