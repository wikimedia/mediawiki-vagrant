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
) {
    include mediawiki

    exec { "mediawiki_user_${username}":
        cwd     => "${mediawiki::dir}/maintenance",
        command => "php5 createAndPromote.php ${username} ${password}",
        unless  => "php5 createAndPromote.php ${username} 2>&1 | grep -q '^Account exists'",
        require => [ Exec['mediawiki_setup'], Env::Var['MW_INSTALL_PATH'] ],
    }
}
