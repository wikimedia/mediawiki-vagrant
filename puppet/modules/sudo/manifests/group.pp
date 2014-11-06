# == Define: sudo::group
#
# Provision sudo rights
#
# === Parameters
#
# [*group*]
#   Group to grant privileges to. Default $title.
#
# [*privileges*]
#   Array of sudoer grants. Default [].
#
# [*ensure*]
#   Whether the file should exist ('present', 'absent'). Default 'present'.
#
# === Example
#
# sudo::group { 'mwdeploy' :
#     privileges => [
#         'ALL = (apache,mwdeploy,l10nupdate) NOPASSWD: ALL',
#         'ALL = (root) NOPASSWD: /sbin/restart hhvm',
#         'ALL = (root) NOPASSWD: /sbin/start hhvm',
#     ]
# }
#
define sudo::group (
    $group      = $title,
    $privileges = [],
    $ensure     = 'present',
) {

    $grantee = "%${group}"
    file { "/etc/sudoers.d/${title}":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        content => template('sudo/sudoers.erb'),
    }
}
