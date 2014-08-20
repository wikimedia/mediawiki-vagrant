# == Class: role::commons
# This role creates one additional wiki, commons.wiki.local.wmftest.net
# which is configured to approximate commons' setup
#
class role::commons {
    require ::role::mediawiki
    include ::role::multimedia
    include ::role::thumb_on_404

    mediawiki::wiki { 'commons': }
    role::thumb_on_404::multiwiki { 'commons': }

    file { '/srv/commonsimages':
        ensure => directory,
        owner  => 'vagrant',
        group  => 'www-data',
        mode   => '0775',
    }

    mediawiki::settings { 'commons:general':
        values => {
            wgUseInstantCommons    => false,
            wgUploadDirectory      => '/srv/commonsimages',
            wgUploadPath           => '/commonsimages',
            wgCrossSiteAJAXdomains => ['*'],
        },
    }

    mediawiki::settings { 'commons_ForeignRepo':
        values => template('role/commons_foreign_repo.php.erb'),
    }

    apache::site_conf { 'custom_images_dir_for_commons':
        site    => $::mediawiki::wiki_name,
        content => template('role/commons_images_folder.conf.erb'),
        require => Mediawiki::Wiki['commons'],
    }

    mediawiki::extension { 'GlobalUsage':
        needs_update => true,
        settings     => {
            wgGlobalUsageDatabase => 'commonswiki',
        },
        require      => Mediawiki::Wiki['commons'],
    }

    exec { 'refresh globalusage table':
        command => 'foreachwiki extensions/GlobalUsage/refreshGlobalimagelinks.php --pages existing,nonexisting',
        cwd     => $::mediawiki::dir,
        user    => 'www-data',
        require => Mediawiki::Extension['GlobalUsage'],
    }
}
