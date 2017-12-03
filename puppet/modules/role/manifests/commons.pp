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

    mediawiki::wiki { 'commons':
        upload_dir => $upload_dir,
        priority   => $::load_early,
    }
    role::thumb_on_404::multiwiki { 'commons': }

    mediawiki::settings { 'commons:general':
        values => {
            wgUseInstantCommons    => false,
            wgCrossSiteAJAXdomains => ['*'],
        },
    }

    mediawiki::settings { 'commons_ForeignRepo':
        values => template('role/commons/foreign_repo.php.erb'),
    }

    mediawiki::extension { 'GlobalUsage':
        needs_update => true,
        settings     => {
            wgGlobalUsageDatabase => 'commonswiki',
        },
        require      => Mediawiki::Wiki['commons'],
    }

    mediawiki::maintenance { 'refresh globalusage table':
        command => '/usr/local/bin/foreachwikiwithextension GlobalUsage extensions/GlobalUsage/refreshGlobalimagelinks.php --pages existing,nonexisting',
        cwd     => $::mediawiki::dir,
        require => Mediawiki::Extension['GlobalUsage'],
    }
}
