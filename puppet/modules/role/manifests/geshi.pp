# == Class: role::geshi
# Configures SyntaxHighlight_GeSHi, an extension for syntax-highlighting
class role::geshi {
    require_package('python-pygments')

    mediawiki::extension { 'SyntaxHighlight_GeSHi':
        composer => true,
        settings => {
            wgPygmentizePath => '/usr/bin/pygmentize',
        },
    }
}
