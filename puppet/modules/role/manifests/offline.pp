# == Class: role::offline
# Installs offline-related extensions/services:
# * Collection[https://www.mediawiki.org/wiki/Extension:Collection]
# * OCG[https://www.mediawiki.org/wiki/Offline_content_generator]
# * ElectronPdfService[https://www.mediawiki.org/wiki/Extension:ElectronPdfService]
# * electron[https://github.com/wikimedia/mediawiki-services-electron-render/blob/master/README.md]
#
class role::offline {
    require ::ocg
    require ::electron

    mediawiki::extension { 'Collection':
        settings => template('role/offline/Collection.php.erb'),
    }
    mediawiki::extension { 'ElectronPdfService':
        settings => {
            wgElectronPdfServiceRESTbaseURL => '/api/rest_v1/page/pdf/',
        },
    }

    $hostname = $::electron::vhost_name
    mediawiki::import::text { 'VagrantRoleOffline':
        content => template('role/offline/VagrantRoleOffline.wiki.erb'),
    }
}

