# vim:set sw=4 ts=4 sts=4 et:

# == Define mediawiki::wiki
#
# Provision a new wiki instance.
#
# === Multi-instance: known limitations
#
# By specifying the *src_dir* parameter it is possible to have multiple wikis,
# each running a separate branch of the mediawiki/core repository.
# There are, however, some limitations.
#
# Currently support for multiple mediawiki source directories is incomplete
# in the following ways:
#
# 1. By default, *::mediawiki::extension* makes config files that are shared by
#  all of the configured wikis, however, that code only clones extensions in
#  to */vagrant/mediawiki/extensions*.  This means that if you have roles
#  enabled that setup any extensions, the source for each extension will need
#  to be manually cloned into each additional mediawiki branch you are using.
# 2. *::mediawiki::settings* has same problem as above
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
#   User name for the initial admin account ($::mediawiki::admin_user).
#   Changing this is not recommended, and can slow provisioning
#   if CentralAuth is enabled.
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
# [*upload_path*]
#   URL path for uploaded content (example: '/images')
#
# [*server_url*]
#   Full base URL of host (example: 'http://mywiki.net:8080').
#
# [*primary_wiki*]
#   Whether this is the primary wiki (default: false)
#
# [*priority*]
#   Position of this wiki in foreachwiki.  Uses the scale of
#   the $::load_* constants from site.php. (default: $::load_normal)
#
# [*wgconf*]
#   Hash of extra wgConf settings for this wiki. One use case for this is
#   selectively disabling a globally installed extension for a particular
#   wiki by setting wmvExtensions[<extension name>] = false. (default: {})
#
# === Examples
#
# Add a wiki named 'testwiki':
#
#     mediawiki::wiki { 'test': }
#
# Disable the CentralAuth extension on a wiki named 'nocawiki':
#
#     mediawiki::wiki { 'noca':
#         wgconf => {
#             'wmvExtensions' => {
#                   'CentralAuth' => false,
#             },
#         },
#     }
#
define mediawiki::wiki(
    $wiki_name    = $title,
    $db_host      = $::mysql::grant_host_name,
    $db_name      = "${title}wiki",
    $db_user      = $::mediawiki::multiwiki::db_user,
    $db_pass      = $::mediawiki::multiwiki::db_pass,
    $admin_user   = $::mediawiki::admin_user,
    $admin_pass   = $::mediawiki::admin_pass,
    $src_dir      = $::mediawiki::dir,
    $cache_dir    = "${::mediawiki::cache_dir}/${title}",
    $upload_dir   = "${::mwv::files_dir}/${title}images",
    $upload_path  = "/${title}images",
    $server_url   = "http://${title}${::mediawiki::multiwiki::base_domain}${::port_fragment}",
    $primary_wiki = false,
    $priority     = $::load_normal,
    $wgconf       = {},
) {
    include ::mwv
    include ::mediawiki
    require ::mediawiki::multiwiki

    mysql::sql { "${db_user}_full_priv_${db_name}":
        sql     => "GRANT ALL PRIVILEGES ON ${db_name}.* TO ${db_user}@${db_host}",
        unless  => "SELECT 1 FROM INFORMATION_SCHEMA.SCHEMA_PRIVILEGES WHERE TABLE_SCHEMA = '${db_name}' AND GRANTEE = \"'${db_user}'@'${db_host}'\" LIMIT 1",
        require => Mysql::User[$db_user],
    }

    $settings_root = "${::mediawiki::multiwiki::settings_root}/${db_name}"
    $settings_dir = "${settings_root}/settings.d"
    $installer_args = {
        wiki       => $db_name,
        dbname     => $db_name,
        dbpass     => $db_pass,
        dbuser     => $db_user,
        pass       => $admin_pass,
        scriptpath => '/w',
        server     => $server_url,
        confpath   => $settings_root,
    }

    file { [$upload_dir, $cache_dir]:
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0755',
    }

    Exec {
        require => [
            File[$cache_dir],
            File[$upload_dir],
        ],
    }

    exec { "${db_name}_setup":
        command => template('mediawiki/wiki/run_installer.erb'),
        unless  => template('mediawiki/wiki/check_installed.erb'),
        user    => 'vagrant',
        require => [
            Class['mysql'],
            File[$settings_root],
            Mysql::Sql["${db_user}_full_priv_${db_name}"],
        ],
        before  => Exec['update_all_databases'],
    }

    exec { "${db_name}_include_extra_settings":
        command => '/bin/echo "include_once \'/vagrant/LocalSettings.php\';" >> LocalSettings.php',
        cwd     => $settings_root,
        unless  => '/bin/grep "/vagrant/LocalSettings.php" LocalSettings.php',
        require => Exec["${db_name}_setup"],
    }

    exec { "${db_name}_copy_LocalSettings":
        command => "/bin/cp ${settings_root}/LocalSettings.php ${src_dir}/LocalSettings.php",
        creates => "${src_dir}/LocalSettings.php",
        require => Exec["${db_name}_include_extra_settings"],
    }

    exec { "update_${db_name}_database":
        command     => "/usr/local/bin/mwscript update.php --wiki ${db_name} --quick",
        refreshonly => true,
        user        => 'www-data',
    }

    $priority_filename = sprintf('%s/%.2d-%s-dbConf.php', $::mediawiki::multiwiki::wiki_priority_dir, $priority, $db_name)
    file { $priority_filename:
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/wiki/dbConf.php.erb'),
    }

    File {
        owner   => $::share_owner,
        group   => $::share_group,
    }

    file { $settings_root:
        ensure => directory,
    }

    # $wgDebugLogFile
    $debug_log_file = "/vagrant/logs/mediawiki-${db_name}-debug.log"

    file { "${settings_root}/wgConf.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/wiki/wgConf.php.erb'),
    }

    file { "/etc/logrotate.d/mediawiki_${db_name}_debug_log":
        content => template('mediawiki/logrotate.d-mediawiki-debug-log.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
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

    # used by ::mediawiki::import::text
    file { "${::mediawiki::page_dir}/wiki/${db_name}":
        ensure => directory,
    }

    apache::site_conf { "${title}_images":
        site    => $::mediawiki::wiki_name,
        content => template('mediawiki/wiki/apache-images.erb'),
    }

    # Provision primary wiki before others
    Mediawiki::Wiki <| primary_wiki == true |> -> Mediawiki::Wiki <| primary_wiki == false |>
    # Provision wikis before adding extensions
    Mediawiki::Wiki <| |> -> MediaWiki::Extension <| |>
}
