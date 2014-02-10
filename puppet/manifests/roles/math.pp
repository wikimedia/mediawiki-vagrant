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
        before       => Exec['compile texvc'],
    }

    exec { 'compile texvc':
        command => 'make',
        cwd     => '/vagrant/mediawiki/extensions/Math/math',
        creates => '/vagrant/mediawiki/extensions/Math/math/texvc',
        require => Package['mediawiki-math', 'ocaml-native-compilers'],
    }

    exec { 'compile texvccheck':
        command => 'make',
        cwd     => '/vagrant/mediawiki/extensions/Math/texvccheck',
        creates => '/vagrant/mediawiki/extensions/Math/texvccheck/texvccheck',
        require => Package['mediawiki-math', 'ocaml-native-compilers'],
    }
}
