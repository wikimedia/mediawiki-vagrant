# == Class: role::mediawiki
# Provisions a MediaWiki instance powered by PHP, MySQL, and redis.
class role::mediawiki {
    include role::generic
    include role::mysql

    # Required to run some tests.
    include packages::php5_tidy

    $wiki_name = 'devwiki'

    # 'forwarded_port' defaults to 8080, but may be overridden by
    # changing the value of 'FORWARDED_PORT' in Vagrantfile.
    $server_url = $::forwarded_port ? {
        undef   => 'http://127.0.0.1',
        default => "http://127.0.0.1:${::forwarded_port}",
    }

    $dir = '/vagrant/mediawiki'
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
        settings_dir => $settings_dir,
        upload_dir   => $upload_dir,
        server_url   => $server_url,
    }
}
