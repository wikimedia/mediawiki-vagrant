# == Class: role::math
#
# The Math extension provides support for rendering mathematical formulas
# on-wiki via texvc.
class role::math {
    include role::mediawiki

    include packages::mediawiki_math
    include packages::ocaml_native_compilers

    mediawiki::extension { 'Math':
        needs_update => true,
        before       => Exec['compile_texvc'],
    }

    exec { 'compile_texvc':
        command => 'make',
        cwd     => "${mediawiki::dir}/extensions/Math/math",
        creates => "${mediawiki::dir}/extensions/Math/math/texvc",
        require => Package['mediawiki-math', 'ocaml-native-compilers'],
    }

    exec { 'compile_texvccheck':
        command => 'make',
        cwd     => "${mediawiki::dir}/extensions/Math/texvccheck",
        creates => "${mediawiki::dir}/extensions/Math/texvccheck/texvccheck",
        require => Package['mediawiki-math', 'ocaml-native-compilers'],
    }
}
