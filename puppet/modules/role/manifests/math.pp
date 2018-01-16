# == Class: role::math
#
# The Math extension provides support for rendering mathematical formulas
# on-wiki via texvc.
class role::math {
    require ::role::mediawiki

    require_package('ghostscript')
    require_package('imagemagick')

    mediawiki::extension { 'Math':
        needs_update  => true,
        browser_tests => true,
    }

    require_package(
            'ocaml-native-compilers',
            'texlive',
            'texlive-bibtex-extra',
            'texlive-font-utils',
            'texlive-fonts-extra',
            'texlive-lang-all',
            'texlive-latex-extra',
            'texlive-math-extra',
            'texlive-pictures',
            'texlive-pstricks',
            'texlive-publishers',
            'texlive-generic-extra'
    )

    exec { 'compile_texvc':
        command => 'make',
        cwd     => "${::mediawiki::dir}/extensions/Math/math",
        creates => "${::mediawiki::dir}/extensions/Math/math/texvc",
        require => [
            Mediawiki::Extension['Math'],
            Package['ocaml-native-compilers'],
        ],
    }

    exec { 'compile_texvccheck':
        command => 'make',
        cwd     => "${::mediawiki::dir}/extensions/Math/texvccheck",
        creates => "${::mediawiki::dir}/extensions/Math/texvccheck/texvccheck",
        require => [
            Mediawiki::Extension['Math'],
            Package['ocaml-native-compilers'],
        ],
    }
}
