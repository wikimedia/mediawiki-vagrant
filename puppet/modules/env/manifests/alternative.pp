# == Define: env::alternative
#
# Control symbolic links in the Debian alternatives system.
#
# === Parameters
#
# [*alternative*]
#   The generic name for the master link.
#
# [*symlink*]
#   The name of the alternative's symlink in the alternatives directory.
#
# [*target*]
#   The alternative being introduced for the master link.
#
# [*priority*]
#   Numeric priority to assign to this target.
#
# === Examples
#
#  env::alternative { 'set_default_php_to_hhvm':
#    alternative => 'php',
#    target      => '/usr/bin/hhvm',
#    priority    => 20,
#  }
#
define env::alternative(
    $alternative,
    $target,
    $priority,
    $symlink = "/usr/bin/${alternative}",
) {
    if !defined( Exec["clear_alternatives_${alternative}"] ) {
        exec { "clear_alternatives_${alternative}":
            command => '/bin/true',
            unless  => "update-alternatives --remove-all ${alternative} || true",
        }
    }

    exec { "install_alternative_${title}":
        command => '/bin/true',
        unless  => "update-alternatives --install ${symlink} ${alternative} ${target} ${priority}",
        require => Exec["clear_alternatives_${alternative}"],
    }
}
