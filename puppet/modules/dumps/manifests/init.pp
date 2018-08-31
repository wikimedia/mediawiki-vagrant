# == Class: dumps
#
# Wiki dumps infrastructure
#
# === Parameters
#
# [*conf_dir*]
#   Path where dump configuration should be provisioned
#
# [*db_user*]
#   MySQL wiki admin user
#
# [*db_pass*]
#   MySQL wiki admin password
#
# [*dumps_dir*]
#   Root directory for this service
#
# [*mediawiki_dir*]
#   Path to the wiki being dumped
#
# [*mwbzutils_dir*]
#   Where to check out our bzip2 utilities
#
# [*mwbzutils_source_dir*]
#   Where bzip2 utility binaries will be built
#
# [*output_dir*]
#   Path where dumps will be written
#
# [*webroot_dir*]
#   Where to output web files
#
class dumps(
    $conf_dir,
    $db_user,
    $db_pass,
    $dumps_dir,
    $mediawiki_dir,
    $mwbzutils_dir,
    $mwbzutils_source_dir,
    $output_dir,
    $site_name,
    $webroot_dir,
) {
    require_package('libbz2-dev')
    require_package('p7zip-full')
    require_package('zlib1g-dev')

    # TODO: pip from requirements.txt once that exists.
    require_package('python-yaml')

    git::clone { 'operations/dumps':
        directory => $dumps_dir,
    }

    service::gitupdate { 'dumps':
        dir => $dumps_dir,
    }

    git::clone { 'operations/dumps/mwbzutils':
        directory => $mwbzutils_dir,
        require   => Git::Clone['operations/dumps'],
    }

    service::gitupdate { 'mwbzutils':
        dir => $mwbzutils_dir,
    }

    exec { 'build mwbzutils':
        command => 'make',
        cwd     => "${mwbzutils_dir}/xmldumps-backup/mwbzutils",
        creates => "${mwbzutils_dir}/xmldumps-backup/mwbzutils/writeuptopageid",
        require => [
            Git::Clone['operations/dumps/mwbzutils'],
            Package['zlib1g-dev'],
        ],
    }

    file { '/etc/wikidump.conf':
        ensure  => present,
        content => template('dumps/wikidump.conf.erb'),
    }

    file { $conf_dir:
        ensure  => directory,
        require => Git::Clone['operations/dumps'],
    }

    # TODO: Pull actual dblist from multiwiki; provision at least two wikis.
    file { "${conf_dir}/all.dblist":
        ensure  => present,
        content => 'wiki',
    }

    file { "${conf_dir}/skip.dblist":
        ensure  => present,
        content => '',
    }

    file { "${conf_dir}/private.dblist":
        ensure  => present,
        content => '',
    }

    file { "${conf_dir}/closed.dblist":
        ensure  => present,
        content => '',
    }

    file { "${conf_dir}/flow.dblist":
        ensure  => present,
        content => '',
    }

    file { "${conf_dir}/tablejobs.yaml":
        ensure  => present,
        content => file('dumps/tablejobs.yaml'),
    }

    file { "${conf_dir}/templs":
        ensure => directory,
    }

    file { "${conf_dir}/templs/report.html":
        ensure  => present,
        content => file('dumps/report.html'),
    }

    file { "${conf_dir}/templs/feed.xml":
        ensure  => present,
        content => file('dumps/feed.xml'),
    }

    file { [$output_dir, "${dumps_dir}/www"]:
        ensure  => directory,
        require => Git::Clone['operations/dumps'],
    }

    apache::site { $site_name:
        ensure  => present,
        content => template('dumps/dumps-apache-site.erb'),
        require => File["${dumps_dir}/www"],
    }

    file { "${output_dir}/temp":
        ensure  => directory,
        owner   => 'vagrant',
        group   => 'www-data',
        mode    => '0775',
        require => File[$output_dir]
    }

    file { '/var/log/wikidatadump':
        ensure => directory,
        owner  => 'vagrant',
        group  => 'www-data',
        mode   => '0775',
    }
}
