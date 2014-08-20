# vim:set sw=4 ts=4 sts=4 et:

# == Define mediawiki::wiki
#
# Provision a new wiki instance.
#
# === Parameters
#
# [*wiki_name*]
#   The name of your site (example: 'devwiki').
#
# [*db_name*]
#   Logical MySQL database name (example: 'devwiki').
#
# [*db_user*]
#   MySQL user to use to connect to the database (example: 'wikidb').
#
# [*db_pass*]
#   Password for MySQL account (example: 'secret123').
#
# [*admin_user*]
#   User name for the initial admin account (example: 'admin').
#
# [*admin_pass*]
#   Initial password for admin account (example: 'secret123').
#
# [*src_dir*]
#   The system path to which MediaWiki files have been installed
#   (example: '/srv/mediawiki/mediawiki').
#
# [*cache_dir*]
#   Directory to use for caching interface messages (l10n cache).
#   (example: '/var/cache/mediawiki').
#
# [*upload_dir*]
#   The file system path of the folder where files will be uploaded
#   (example: '/srv/mediawiki/images').
#
# [*server_url*]
#   Full base URL of host (example: 'http://mywiki.net:8080').
#
define mediawiki::wiki(
    $wiki_name    = $title,
    $db_name      = "${title}wiki",
    $db_user      = $::mediawiki::db_user,
    $db_pass      = $::mediawiki::db_pass,
    $admin_user   = $::mediawiki::admin_user,
    $admin_pass   = $::mediawiki::admin_pass,
    $src_dir      = $::mediawiki::dir,
    $cache_dir    = $::mediawiki::cache_dir,
    $upload_dir   = "/srv/${title}images",
    $server_url   = "http://${title}${::mediawiki::multiwiki::base_domain}${::port_fragment}",
    $primary_wiki = false,
) {
    include ::mediawiki
    require ::mediawiki::multiwiki

    $settings_root = "${::mediawiki::multiwiki::settings_root}/${db_name}"
    $settings_dir = "${settings_root}/settings.d"
    $installer_args = {
        dbname     => $db_name,
        dbpass     => $db_pass,
        dbuser     => $db_user,
        pass       => $admin_pass,
        scriptpath => '/w',
        server     => $server_url,
        confpath   => $settings_root,
    }

    exec { "${db_name}_setup":
        command => template('mediawiki/wiki/run_installer.erb'),
        creates => "${settings_root}/LocalSettings.php",
    }

    exec { "${db_name}_include_extra_settings":
        command => 'echo "include_once \'/vagrant/LocalSettings.php\';" >> LocalSettings.php',
        cwd     => $settings_root,
        unless  => 'grep "/vagrant/LocalSettings.php" LocalSettings.php',
        require => Exec["${db_name}_setup"],
    }

    # Cleanup LocalSettings.php if database is not found
    exec { "${db_name}_check_settings":
        command => "rm -f ${settings_root}/LocalSettings.php",
        unless  => "mwscript sql.php --wikidb=${db_name} </dev/null",
        notify  => Exec["${db_name}_setup"],
        require => Service['mysql'],
    }

    exec { "update_${db_name}_database":
        command     => "mwscript update.php --wiki ${db_name} --quick",
        refreshonly => true,
        user        => 'www-data',
    }

    File {
        owner   => $::share_owner,
        group   => $::share_group,
    }

    file { $settings_root:
        ensure => directory,
    }

    file { "${settings_root}/wgConf.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/wiki/wgConf.php.erb'),
    }

    file { "${settings_root}/dbConf.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/wiki/dbConf.php.erb'),
    }

    file { $settings_dir:
        ensure  => directory,
    }

    file { "${settings_dir}/puppet-managed":
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/mediawiki/wiki/settings.d-empty',
    }

    # Provision primary wiki before others
    Mediawiki::Wiki <| primary_wiki == true |> -> Mediawiki::Wiki <| primary_wiki == false |>
    # Provision wikis before adding extensions
    Mediawiki::Wiki <| |> -> MediaWiki::Extension <| |>
}
