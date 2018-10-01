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
    $dblists_dir,
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
    require_package('php-bz2')

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

    file { $conf_dir:
        ensure  => directory,
        require => Git::Clone['operations/dumps'],
    }

    file { "${conf_dir}/wikidump.conf.dumps":
        ensure  => present,
        content => template('dumps/wikidump.conf.erb'),
    }

    # TODO: Pull actual dblist from multiwiki; provision at least two wikis.
    file { $dblists_dir:
        ensure  => directory,
        require => Git::Clone['operations/dumps'],
    }

    file { "${dblists_dir}/all.dblist":
        ensure  => present,
        content => "wiki\n",
    }

    file { "${dblists_dir}/skip.dblist":
        ensure  => present,
        content => '',
    }

    file { "${dblists_dir}/private.dblist":
        ensure  => present,
        content => '',
    }

    file { "${dblists_dir}/closed.dblist":
        ensure  => present,
        content => '',
    }

    file { "${dblists_dir}/flow.dblist":
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

    user { 'dumpsgen':
        ensure     => present,
        home       => '/var/lib/dumpsgen',
        shell      => '/bin/bash',
        groups     => 'www-data',
        system     => true,
        managehome => true,
    }

    file { $output_dir:
        ensure  => directory,
        owner   => 'dumpsgen',
        group   => 'www-data',
        mode    => '0775',
        require => Git::Clone['operations/dumps'],
    }

    apache::site { $site_name:
        ensure  => present,
        content => template('dumps/dumps-apache-site.erb'),
        require => File[$output_dir],
    }

    file { "${output_dir}/temp":
        ensure  => directory,
        owner   => 'dumpsgen',
        group   => 'www-data',
        mode    => '0775',
        require => File[$output_dir],
    }

    file { "${output_dir}/otherdumps":
        ensure  => directory,
        owner   => 'dumpsgen',
        group   => 'www-data',
        mode    => '0775',
        require => File[$output_dir],
    }

    # this horrid thing is because the dumpTextPass.php script
    # expects the MW and multiversion layout to be different than
    # it is in mw vagrant.
    file { "${mediawiki::dir}/../multiversion":
        ensure => link,
        target => "${mediawiki::apache::docroot}/w",
    }

    file { '/home/vagrant/README_vagrant_dumps.txt':
        ensure  => present,
        content => template('dumps/README_vagrant_dumps.txt.erb'),
    }

    file { '/usr/local/etc/set_dump_dirs.sh':
        ensure  => present,
        content => template('dumps/set_dump_dirs.sh.erb'),
    }

    file { '/var/log/wikidatadump':
        ensure => directory,
        owner  => 'dumpsgen',
        group  => 'www-data',
        mode   => '0775',
    }
}
