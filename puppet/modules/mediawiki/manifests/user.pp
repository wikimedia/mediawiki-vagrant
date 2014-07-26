# == Define: mediawiki::user
#
# Uses MediaWiki's maintenance scripts to create a MediaWiki account.
#
# === Parameters
#
# [*username*]
#   User name of account to create. Defaults to the resource title.
#
# [*password*]
#   Password for the new account.
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
    $wiki     = $::mediawiki::db_name,
) {
    include mediawiki

    exec { "mediawiki_user_${username}":
        command => "mwscript createAndPromote.php --wiki=${wiki} ${username} ${password}",
        unless  => "mwscript createAndPromote.php --wiki=${wiki} ${username} 2>&1 | grep -q '^Account exists'",
        user    => 'www-data',
        require => [
            MediaWiki::Wiki[$::mediawiki::wiki_name],
            Env::Var['MW_INSTALL_PATH'],
        ],
    }
}
