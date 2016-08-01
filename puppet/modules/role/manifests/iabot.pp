# == Class: role::iabot
#
# Provision and configure InternetArchiveBot for local testing
#
# == Parameters:
# [*deploy_dir*]
#   Directory to clone git repos in.
# [*remote*]
#   Remote URL for the repository.
# [*branch*]
#   Name of branch to check out.
# [*user*]
#   Wiki user for InternetArchiveBot
# [*password*]
#   Wiki password for InternetArchiveBot
# [*consumer_key*]
#   OAuth consumer key
# [*consumer_secret*]
#   OAuth consumer secret
# [*srv_secret_key*]
#   OAuth server-side secret key
# [*access_token*]
#   OAuth access token
# [*access_secret*]
#   OAuth access secret
# [*srv_access_secret*]
#   OAuth server-side access secret
#
# == Using an alternate github fork
# Set role::iabot::remote in hiera:
#
#   $ vagrant hiera role::iabot::remote https://github.com/wikimedia/Cyberbot_II
#
class role::iabot (
    $deploy_dir,
    $remote,
    $branch,
    $user,
    $password,
    $consumer_key,
    $consumer_secret,
    $srv_secret_key,
    $access_token,
    $access_secret,
    $srv_access_secret,
) {
    include ::role::mediawiki

    $ia_dir = "${deploy_dir}/iabot"
    git::clone { 'iabot':
        directory => $ia_dir,
        remote    => $remote,
        branch    => $branch,
    }

    mysql::db { 'iabot': }
    mysql::user { 'iabot':
        password => 'iabot',
        # The bot script autocreates tables
        grant    => 'ALL ON iabot.*',
    }

    mediawiki::user { $user:
        password => $password,
    }
    if defined(Class['role::centralauth']) {
      role::centralauth::migrate_user { $user: }
    }

    role::oauth::consumer { 'InternetArchiveBot':
        description   => 'InternetArchiveBot',
        consumer_key  => $consumer_key,
        secret_key    => $srv_secret_key,
        callback_url  => '/wiki/Special:OAuth/verified',
        # Grants from list at https://en.wikipedia.org/wiki/Special:OAuthListConsumers/view/ad8e33572688dd300d2b726bee409f5d
        grants        => [
            'useoauth',
            'highvolume',
            'editpage',
            'editprotected',
            'editmycssjs',
            'createeditmovepage',
            'uploadfile',
            'uploadeditmovefile',
            'patrol',
            'rollback',
            'viewmywatchlist',
            'editmywatchlist',
            'sendemail',
            'createaccount',
        ],
        user          => $user,
        owner_only    => true,
        access_token  => $access_token,
        access_secret => $srv_access_secret,
    }

    file { "${ia_dir}/IABot/deadlink.config.local.inc.php":
        ensure  => 'present',
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => '0664',
        content => template('role/iabot/config.php.erb'),
        require => [
            Git::Clone['iabot'],
        ],
    }

    mediawiki::import::text{ "User:${user}/Dead-links.js":
        content => template('role/iabot/Dead-links.wiki.erb'),
        require => Mediawiki::User[$user],
    }
}
# vim:sw=4:ts=4:sts=4:et:ft=puppet:
