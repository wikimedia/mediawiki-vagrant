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
# [*base_domain*]
#   Base domain to use to construct FQDN of wikis.
#
# [*script_dir*]
#   Apache vhost document root.
#
# [*settings_root*]
#   Location of settings files.
#
class mediawiki::multiwiki(
    $base_domain,
    $script_dir,
    $settings_root,
) {

    File {
        owner => 'vagrant',
        group => 'www-data',
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
        ensure  => directory,
        mode    => '0755',
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
        ensure  => present,
        mode    => '0644',
        source  => 'puppet:///modules/mediawiki/multiwiki/stub.php',
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

    file { "${script_dir}/MWVersion.php":
        ensure  => present,
        mode    => '0644',
        content => template('mediawiki/docroot/w/MWVersion.php.erb'),
    }

    file { "${script_dir}/assets":
        ensure => link,
        target => "${::mediawiki::dir}/assets",
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
}
