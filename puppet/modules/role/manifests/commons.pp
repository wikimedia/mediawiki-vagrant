# == Class: role::commons
# This role creates one additional wiki, commons.wiki.local.wmftest.net
# which is configured to approximate commons' setup
#
# [*upload_dir*]
#   Directory where files uploaded to commons will be stored.
#
class role::commons(
    $upload_dir,
) {
    require ::role::mediawiki
    include ::role::multimedia
    include ::role::thumb_on_404

    mediawiki::wiki { 'commons': }
    role::thumb_on_404::multiwiki { 'commons': }

    mediawiki::settings { 'commons:general':
        values => {
            wgUseInstantCommons    => false,
            wgUploadDirectory      => $upload_dir,
            wgUploadPath           => '/commonsimages',
            wgCrossSiteAJAXdomains => ['*'],
        },
        require => File[$upload_dir],
    }

    file { $upload_dir:
        ensure => directory,
        owner  => 'vagrant',
        group  => 'www-data',
        mode   => '0775',
    }

    mediawiki::settings { 'commons_ForeignRepo':
        values => template('role/commons/foreign_repo.php.erb'),
    }

    apache::site_conf { 'custom_images_dir_for_commons':
        site    => $::mediawiki::wiki_name,
        content => template('role/commons/images_folder.conf.erb'),
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
