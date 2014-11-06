# == Define: sudo::user
#
# Provision sudo rights
#
# === Parameters
#
# [*user*]
#   User to grant privileges to. Default $title.
#
# [*privileges*]
#   Array of sudoer grants. Default [].
#
# [*ensure*]
#   Whether the file should exist ('present', 'absent'). Default 'present'.
#
# === Example
#
# sudo::user { 'mwdeploy' :
#     privileges => [
#         'ALL = (apache,mwdeploy,l10nupdate) NOPASSWD: ALL',
#         'ALL = (root) NOPASSWD: /sbin/restart hhvm',
#         'ALL = (root) NOPASSWD: /sbin/start hhvm',
#     ]
# }
#
define sudo::user (
    $user       = $title,
    $privileges = [],
    $ensure     = 'present',
) {

    $grantee = $user
    file { "/etc/sudoers.d/${title}":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        content => template('sudo/sudoers.erb'),
    }
}
