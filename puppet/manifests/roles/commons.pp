# == Class: role::commons
# This role creates one additional wiki, commons.wiki.local.wmftest.net
# which is configured to approximate commons' setup
#
class role::commons {
    include ::role::mediawiki
    include ::role::multimedia
    require ::role::uploadwizard
    require ::role::thumb_on_404

    multiwiki::wiki { 'commons': }
    role::uploadwizard::multiwiki { 'commons': }
    role::thumb_on_404::multiwiki { 'commons': }

    file { '/srv/commonsimages':
        ensure => directory,
        owner  => 'vagrant',
        group  => 'www-data',
        mode   => '0775',
    }

    multiwiki::settings { 'commons:general':
        values => {
            wgUseInstantCommons => false,
            wgUploadDirectory   => '/srv/commonsimages',
            wgUploadPath        => '/commonsimages'
        },
    }

    mediawiki::settings { 'commons_ForeignRepo':
        values => template('commons_foreign_repo.php.erb'),
    }

    apache::site_conf { 'Custom /images for commons multiwiki':
        site    => 'multiwiki',
        content => template('commons_images_folder.conf.erb'),
    }
}
