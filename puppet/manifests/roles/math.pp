# == Class: role::math
#
# The Math extension provides support for rendering mathematical formulas
# on-wiki via texvc.
class role::math {
    include role::mediawiki

    require_package('ghostscript')
    require_package('imagemagick')

    mediawiki::extension { 'Math':
        needs_update  => true,
        browser_tests => true,
    }

    package { [
            'ocaml-native-compilers',
            'texlive',
            'texlive-bibtex-extra',
            'texlive-font-utils',
            'texlive-fonts-extra',
            'texlive-lang-croatian',
            'texlive-lang-cyrillic',
            'texlive-lang-czechslovak',
            'texlive-lang-danish',
            'texlive-lang-dutch',
            'texlive-lang-finnish',
            'texlive-lang-french',
            'texlive-lang-german',
            'texlive-lang-greek',
            'texlive-lang-hungarian',
            'texlive-lang-italian',
            'texlive-lang-latin',
            'texlive-lang-mongolian',
            'texlive-lang-norwegian',
            'texlive-lang-other',
            'texlive-lang-polish',
            'texlive-lang-portuguese',
            'texlive-lang-spanish',
            'texlive-lang-swedish',
            'texlive-lang-vietnamese',
            'texlive-latex-extra',
            'texlive-math-extra',
            'texlive-pictures',
            'texlive-pstricks',
            'texlive-publishers',
        ]:
    }

    exec { 'compile_texvc':
        command => 'make',
        cwd     => "${mediawiki::dir}/extensions/Math/math",
        creates => "${mediawiki::dir}/extensions/Math/math/texvc",
        require => [
            Mediawiki::Extension['Math'],
            Package['ocaml-native-compilers'],
        ],
    }

    exec { 'compile_texvccheck':
        command => 'make',
        cwd     => "${mediawiki::dir}/extensions/Math/texvccheck",
        creates => "${mediawiki::dir}/extensions/Math/texvccheck/texvccheck",
        require => [
            Mediawiki::Extension['Math'],
            Package['ocaml-native-compilers'],
        ],
    }
}
