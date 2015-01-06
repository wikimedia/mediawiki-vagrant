# == Class: role::private
# This role creates one additional wiki, private.wiki.local.wmftest.net
# which is configured to approximate the setup of the private WMF wikis
#
class role::private {
    require ::role::mediawiki

    mediawiki::wiki { 'private': }

    mediawiki::settings { 'private:general':
        values => {
            wgUploadPath                        => '/w/img_auth.php',
            wgThumbnailScriptPath               => '/w/thumb.php',
            wgWhitelistRead                     => ['Main Page', 'Special:UserLogin', 'Special:UserLogout'],
            wgEmailAuthentication               => false,
            wgBlockDisablesLogin                => true,
            wgVisualEditorParsoidForwardCookies => true,
        },
    }
    mediawiki::settings { 'private:repo':
        values => template('role/private_local_repo.php.erb'),
    }
    mediawiki::settings { 'private:rights':
        values => template('role/private_rights.php.erb'),
    }

    apache::site_conf { 'private_deny_images':
        site    => $::mediawiki::wiki_name,
        content => template('role/private_deny_images.conf.erb'),
        require => Mediawiki::Wiki['private'],
    }

    # GlobalUsage (from the commons role) should be disabled but there is no easy way to do that
}

