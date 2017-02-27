# == Class: role::wikilabels
# This role installs the [ORES][https://ores.wikimedia.org/] and
# [wikilabels][https://meta.wikimedia.org/wiki/Wiki_labels] services.
#
class role::wikilabels {
    include ::wikilabels

    $wikilabels_hostname = $::wikilabels::vhost_name

    mediawiki::import::text { 'VagrantRoleWikilabels':
        content => template('role/wikilabels/VagrantRoleWikilabels.wiki.erb'),
    }
}

