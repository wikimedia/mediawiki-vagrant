# vim:set sw=4 ts=4 sts=4 et:

# == Define multiwiki::wiki
#
# Provision a new multiwiki instance.
#
# The resource title will be used as the base name of the new wiki. It will be
# given the URL http://${title}.wiki.local.wmftest.net and a database named
# "${title}wiki".
#
# === Examples
#
#   multiwiki::wiki{ 'mywiki': }
#
# See multiwiki::extension and multiwiki::settings to configure the wiki.
#
define multiwiki::wiki {
    require ::multiwiki
    include role::mysql

    $wikidb = "${title}wiki"
    $db_user = 'root'
    $db_pass = $::role::mysql::db_pass
    $admin_user = 'admin'
    $admin_pass = 'vagrant'
    $server_url = "http://${title}.wiki.local.wmftest.net:${::forwarded_port}"

    $multiwiki_dir = "${::multiwiki::settings_root}/${wikidb}"
    $settings_dir = "${multiwiki_dir}/settings.d"

    $installer_args = {
        dbname     => $wikidb,
        dbpass     => $db_pass,
        dbuser     => $db_user,
        pass       => $admin_pass,
        scriptpath => '/w',
        server     => $server_url,
        confpath   => $multiwiki_dir,
    }

    exec { "${wikidb}_setup":
        command => template('multiwiki/run_installer.erb'),
        creates => "${multiwiki_dir}/LocalSettings.php",
    }

    # Cleanup LocalSettings.php if database is not found
    exec { "${wikidb}_check_settings":
        command => "rm -f ${multiwiki_dir}/LocalSettings.php",
        notify  => Exec["${wikidb}_setup"],
        unless  => "mwscript sql.php --wikidb=${wikidb} </dev/null",
    }

    exec { "update_${wikidb}_database":
        command     => "mwscript update.php --wiki ${wikidb} --quick",
        refreshonly => true,
        user        => 'www-data',
    }

    File {
        owner   => $::share_owner,
        group   => $::share_group,
    }

    file { $multiwiki_dir:
        ensure => directory,
    }

    file { "${multiwiki_dir}/wgConf.php":
        ensure  => present,
        mode    => '0644',
        content => template('multiwiki/wgConf.php.erb'),
    }

    file { "${multiwiki_dir}/dbConf.php":
        ensure  => present,
        mode    => '0644',
        content => template('multiwiki/dbConf.php.erb'),
    }

    file { $settings_dir:
        ensure  => directory,
    }

    file { "${settings_dir}/puppet-managed":
        ensure  => directory,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/multiwiki/settings.d-empty',
    }
}
