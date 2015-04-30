# == Define: mediawiki::user
#
# Uses MediaWiki's maintenance scripts to create a MediaWiki account.
#
# === Parameters
#
# [*password*]
#   Password for the new account.
#
# [*username*]
#   User name of account to create. Defaults to the resource title.
#
# [*email*]
#   Email address for the new account.
#
# [*wiki*]
#   Wiki to create account on. Defaults to the primary wiki.
#
# === Examples
#
#  Create a MediaWiki account for user 'sumana':
#
#  mediawiki::user { 'sumana':
#     password => 'secretpassword',
#  }
#
define mediawiki::user(
    $password,
    $username = $title,
    $email    = undef,
    $wiki     = $::mediawiki::db_name,
) {
    include ::mediawiki

    exec { "mediawiki_user_${username}":
        # lint:ignore:80chars
        command => "/usr/local/bin/mwscript createAndPromote.php --wiki=${wiki} ${username} ${password}",
        unless  => "/usr/local/bin/mwscript createAndPromote.php --wiki=${wiki} ${username} 2>&1 | grep -Pq '^#?Account exists'",
        # lint:endignore
        user    => 'www-data',
        require => [
            MediaWiki::Wiki[$::mediawiki::wiki_name],
            Env::Var['MW_INSTALL_PATH'],
        ],
    }

    if $email {
        exec { "mediawiki_user_${username}_email":
            command     => template('mediawiki/set_user_email.erb'),
            user        => 'www-data',
            refreshonly => true,
            subscribe   => Exec["mediawiki_user_${username}"],
        }
    }
}
