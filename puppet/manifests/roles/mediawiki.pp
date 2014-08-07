# == Class: role::mediawiki
# Provisions a MediaWiki instance powered by PHP, MySQL, and redis.
#
# === Parameters
#
# [*hostname*]
#   Hostname for the main wiki. Default '127.0.0.1'
class role::mediawiki(
    $hostname = '127.0.0.1',
){
    include role::generic
    include role::mysql

    require_package('php5-tidy')
    require_package('tidy')

    $wiki_name = 'devwiki'

    # 'forwarded_port' defaults to 8080, but may be overridden by
    # changing the value of 'FORWARDED_PORT' in Vagrantfile.
    $server_url = $::forwarded_port ? {
        undef   => "http://${hostname}",
        default => "http://${hostname}:${::forwarded_port}",
    }

    $dir = '/vagrant/mediawiki'
    $cache_dir = '/var/cache/mediawiki'
    $settings_dir = '/vagrant/settings.d'
    $upload_dir = '/srv/images'

    # Database access
    $db_name = $::role::mysql::db_name
    $db_user = 'root'
    $db_pass = $::role::mysql::db_pass

    # Initial admin account
    $admin_user = 'admin'
    $admin_pass = 'vagrant'

    class { '::redis':
        persist    => true,
        max_memory => '64M',
    }

    class { '::mediawiki':
        wiki_name    => $wiki_name,
        admin_user   => $admin_user,
        admin_pass   => $admin_pass,
        db_name      => $db_name,
        db_pass      => $db_pass,
        db_user      => $db_user,
        dir          => $dir,
        cache_dir    => $cache_dir,
        settings_dir => $settings_dir,
        upload_dir   => $upload_dir,
        server_url   => $server_url,
    }
}
