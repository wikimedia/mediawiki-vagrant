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

    exec { "${wikidb} setup":
        command => template('multiwiki/run_installer.erb'),
        creates => "${multiwiki_dir}/LocalSettings.php",
    }

    # Cleanup LocalSettings.php if database is not found
    exec { "${wikidb} check settings":
        command => "rm -f ${multiwiki_dir}/LocalSettings.php",
        notify  => Exec["${wikidb} setup"],
        unless  => "mwscript sql.php --wikidb=${wikidb} </dev/null",
    }

    exec { "update ${wikidb} database":
        command     => "mwscript update.php --wiki ${wikidb} --quick",
        refreshonly => true,
        user        => 'www-data',
    }

    file { $multiwiki_dir:
        ensure => directory,
        owner  => 'vagrant',
        group  => 'www-data',
        mode   => '0755',
    }

    file { "${multiwiki_dir}/wgConf.php":
        ensure  => present,
        owner   => 'vagrant',
        group   => 'www-data',
        mode    => '0644',
        content => template('multiwiki/wgConf.php.erb'),
        require => File[$multiwiki_dir],
    }

    file { "${multiwiki_dir}/dbConf.php":
        ensure  => present,
        owner   => 'vagrant',
        group   => 'www-data',
        mode    => '0644',
        content => template('multiwiki/dbConf.php.erb'),
        require => File[$multiwiki_dir],
    }

    file { $settings_dir:
        ensure  => directory,
        owner   => 'vagrant',
        group   => 'www-data',
        mode    => '0755',
        require => File[$multiwiki_dir],
    }

    file { "${settings_dir}/puppet-managed":
        ensure  => directory,
        owner   => 'vagrant',
        group   => 'www-data',
        mode    => undef,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/multiwiki/settings.d-empty',
        require => File[$settings_dir],
    }
}
