# == Class: role::whoops
# Installs the Whoops[https://www.mediawiki.org/wiki/Extension:Whoops]
# extension for nice exception display.
#
class role::whoops () {
    mediawiki::extension { 'Whoops':
        settings => {
            wgShowExceptionDetails => true,
            wgShowDBErrorBacktrace => true,
        },
        composer => true,
    }
}

