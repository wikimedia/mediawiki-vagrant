# == Class: role::offline
# Installs offline-related extensions/services:
# * Collection[https://www.mediawiki.org/wiki/Extension:Collection]
# * proton[https://www.mediawiki.org/wiki/Proton]
#
class role::offline {
    require ::proton

    mediawiki::extension { 'Collection':
        settings => template('role/offline/Collection.php.erb'),
    }

    mediawiki::import::text { 'VagrantRoleOffline':
        content => template('role/offline/VagrantRoleOffline.wiki.erb'),
    }
}
