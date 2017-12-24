# == Class: mediawiki::multiwiki
#
# Basic support for running multiple wikis. Sets up the script dir for the
# MediaWiki vhost that bootstraps requests very similarly to the
# [[:mediawki:Wikifarm#Wikimedia_Method|Wikimedia Method]]. It also installs
# helper scripts such as `mwscript` and `foreachwiki` which assist in running
# maintenance scripts on particular wikis.
#
# Use mediawiki::wiki to define a new wiki.
#
# === Parameters
#
# [*default_wiki*]
#   FQDN of default wiki.
#
# [*base_domain*]
#   Base domain to use to construct FQDN of wikis.
#
# [*script_dir*]
#   Apache vhost document root.
#
# [*wiki_priority_dir*]
#   The directory used to control wiki priority.  This is primarily
#   intended for update_all_databases, but affects alldbs and all uses
#   of foreachwiki
#
# [*settings_root*]
#   Location of settings files.
#
# [*db_host*]
#   Hostname used for connecting to MySQL
#
# [*db_user*]
#   Database user used by MediaWiki for main database
#
# [*db_pass*]
#   Database password used by MediaWiki for main database
#
# [*extension_db_cluster*]
#   Cluster used for extension data (refers to wgExternalServers key)
#
# [*extension_cluster_shared_db_name*]
#   Database on the extension cluster (potentially) shared by multiple
#   extensions.  The cluster can have additional databases, though.
#
# [*extension_cluster_db_user*]
#   Database user used for extension cluster
#
# [*extension_cluster_db_pass*]
#   Database password used for extension cluster
class mediawiki::multiwiki(
    $default_wiki,
    $base_domain,
    $script_dir,
    $wiki_priority_dir,
    $settings_root,
    $db_host,
    $db_user,
    $db_pass,
    $extension_db_cluster,
    $extension_cluster_shared_db_name,
    $extension_cluster_db_user,
    $extension_cluster_db_pass,
) {

    File {
        owner => 'vagrant',
        group => 'www-data',
    }

    mysql::user { $db_user:
        password => $db_pass,
        grant    => 'CREATE ON *.*'
    }

    file { $settings_root:
        ensure  => directory,
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => '0755',
        recurse => true,
        purge   => true,
        force   => true,
    }

    mysql::user { $extension_cluster_db_user:
        password => $extension_cluster_db_pass,
        grant    => "ALL PRIVILEGES ON ${extension_cluster_shared_db_name}.*"
    }

    # This does not need to be the only DB on the cluster,
    # but we set it up in multiwiki because in production
    # there is a single DB used by multiple extensions,
    # (BounceHandler, ContentTranslation, Echo), so there
    # is not a natural extension role that should own it.
    mysql::db { $extension_cluster_shared_db_name: }

    file { "${settings_root}/CommonSettings.php":
        ensure  => present,
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => '0644',
        content => template('mediawiki/multiwiki/CommonSettings.php.erb'),
    }

    file { "${settings_root}/LoadWgConf.php":
        ensure  => present,
        owner   => $::share_owner,
        group   => $::share_group,
        mode    => '0644',
        content => template('mediawiki/multiwiki/LoadWgConf.php.erb'),
    }

    file { $script_dir:
        ensure => directory,
        mode   => '0755',
    }

    file { [
            "${script_dir}/api.php",
            "${script_dir}/img_auth.php",
            "${script_dir}/index.php",
            "${script_dir}/load.php",
            "${script_dir}/opensearch_desc.php",
            "${script_dir}/thumb.php",
            "${script_dir}/thumb_handler.php",
        ]:
        ensure => present,
        mode   => '0644',
        source => 'puppet:///modules/mediawiki/multiwiki/stub.php',
    }

    file { "${script_dir}/dblist.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/docroot/w/dblist.php.erb'),
    }

    file { "${script_dir}/defines.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/docroot/w/defines.php.erb'),
    }

    file { "${script_dir}/missing.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/docroot/w/missing.php.erb'),
    }

    file { "${script_dir}/MWMultiVersion.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/docroot/w/MWMultiVersion.php.erb'),
    }

    file { "${script_dir}/MWScript.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/docroot/w/MWScript.php.erb'),
    }

    file { "${script_dir}/RunJobs.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/docroot/w/RunJobs.php.erb'),
    }

    file { "${script_dir}/docs":
        ensure => link,
        target => "${::mediawiki::dir}/docs",
    }

    file { "${script_dir}/extensions":
        ensure => link,
        target => "${::mediawiki::dir}/extensions",
    }

    file { "${script_dir}/resources":
        ensure => link,
        target => "${::mediawiki::dir}/resources",
    }

    file { "${script_dir}/mw-config":
        ensure => link,
        target => "${::mediawiki::dir}/mw-config",
    }

    file { "${script_dir}/skins":
        ensure => link,
        target => "${::mediawiki::dir}/skins",
    }

    file { "${script_dir}/tests":
        ensure => link,
        target => "${::mediawiki::dir}/tests",
    }

    file { "${script_dir}/COPYING":
        ensure => link,
        target => "${::mediawiki::dir}/COPYING",
    }

    file { "${script_dir}/CREDITS":
        ensure => link,
        target => "${::mediawiki::dir}/CREDITS",
    }

    file { $wiki_priority_dir:
        ensure  => directory,
        owner   => $::share_owner,
        group   => $::share_group,
        recurse => true,
        purge   => true,
        force   => true,
        source  => 'puppet:///modules/mediawiki/multiwiki/priority-empty',
    }

    file { '/usr/local/bin/multiversion-install':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('mediawiki/multiwiki/multiversion-install.erb'),
    }

    file { '/usr/local/bin/mwscript':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('mediawiki/multiwiki/mwscript.erb'),
    }

    file { '/usr/local/bin/alldbs':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('mediawiki/multiwiki/alldbs.erb'),
    }

    file { '/usr/local/bin/foreachwiki':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('mediawiki/multiwiki/foreachwiki.erb'),
    }

    file { '/usr/local/bin/foreachwikiwithextension':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('mediawiki/multiwiki/foreachwikiwithextension.erb'),
    }

    file { '/usr/local/bin/wikihasextension':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('mediawiki/multiwiki/wikihasextension.erb'),
    }

    file { '/usr/local/bin/sql':
        ensure  => link,
        target  => '/usr/bin/mysql',
        require => Package['mariadb-server'],
    }
}
