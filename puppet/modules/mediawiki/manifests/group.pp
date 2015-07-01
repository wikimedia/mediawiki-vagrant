# == Define mediawiki::group
#
# Create a group, or assign additional properties to it.
#
# === Parameters
#
# [*wiki*]
#   Wiki name to apply settings to
#
# [*group_name*]
#   Group name
#
# [*grant_permissions*]
#   Array of permissions (rights) to grant through $wgGroupPermissions
#   This does not remove rights the group already grants.
define mediawiki::group(
    $wiki,
    $group_name,
    $grant_permissions = [],
) {
    $settings = regsubst($grant_permissions, '(.*)',
        "\$wgGroupPermissions['${group_name}']['\\1'] = true;")

    mediawiki::settings { "${title}_group":
        ensure => 'present',
        wiki   => $wiki,
        values => join($settings, "\n"),
    }
}
