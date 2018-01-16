# == Class: role::scribunto
# Configures Scribunto, an extension for embedding scripting languages
# in MediaWiki.
class role::scribunto {
    include ::role::codeeditor
    include ::role::syntaxhighlight
    include ::mediawiki::extension::scribunto

    require_package('php-luasandbox')

    mediawiki::extension { 'Scribunto':
        settings => [
            '$wgScribuntoEngineConf["luasandbox"]["profilerPeriod"] = false',
            '$wgScribuntoDefaultEngine = "luasandbox"',
            '$wgScribuntoUseGeSHi      = true',
            '$wgScribuntoUseCodeEditor = true',
        ],
        notify   => Service['apache2'],
        require  => [
            Mediawiki::Extension['CodeEditor'],
            Mediawiki::Extension['SyntaxHighlight_GeSHi'],
            Package['php-luasandbox'],
        ],
    }
}
