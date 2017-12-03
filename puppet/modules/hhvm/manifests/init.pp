# == Class: hhvm
#
# This module provisions HHVM -- an open-source, high-performance
# virtual machine for PHP.
#
# The layout of configuration files in /etc/hhvm is as follows:
#
#   /etc/hhvm
#   ├── php.ini  # Settings for CLI mode
#   └── fcgi.ini # Settings for FastCGI mode
#
# The CLI configs are located in the paths HHVM automatically loads by
# default. This makes it easy to invoke HHVM from the command line,
# because no special arguments are required.
#
# The exact purpose of certain options is a little mysterious. The
# documentation is getting better, but expect to have to dig around in
# the source code.
#
# == Parameters:
#
# [*common_settings*]
#   A hash of default php.ini settings that apply to both CLI and FastCGI
#   mode.
#
# [*fcgi_settings*]
#   A hash of php.ini settings for that only apply to FastCGI mode.
#
# [*logroot*]
#   Parent directory to write log files to. An 'hhvm' subdirectory will be
#   made here to store access and error logs and core dumps . (eg /var/log or
#   /vagrant/logs)
#
# [*hhbc_dir*]
#   Parent directory to store shared hhbc bytecode cache files in.
#
# [*docroot*]
#   Web server docroot directory.
#
# [*admin_site_name*]
#   Hostname for HHVM admin vhost
#
class hhvm (
    $common_settings,
    $fcgi_settings,
    $logroot,
    $hhbc_dir,
    $docroot,
    $admin_site_name,
) {
    include ::apache
    include ::apache::mod::proxy_fcgi

    $ext_pkgs = [ 'hhvm-luasandbox', 'hhvm-tidy', 'hhvm-wikidiff2' ]
    package { [ 'hhvm', 'hhvm-dev' ]:
        ensure => latest,
    }
    package { $ext_pkgs:
        ensure => latest,
    }

    File {
        require => Package['hhvm'],
    }

    file { '/etc/hhvm':
        ensure => directory,
        owner  => 'root',
        group  => 'root',
        mode   => '0555',
    }

    file { '/etc/hhvm/php.ini':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => php_ini($common_settings),
    }

    file { '/etc/hhvm/server.ini':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => php_ini($common_settings, $fcgi_settings),
    }

    file { '/etc/default/hhvm':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('hhvm/hhvm.default.erb'),
    }

    # Log directory may be on a host share that doesn't let us set user:group
    # ownership, so just make a world writable directory. This is a dev
    # environment after all and not a high security multi-tenant system.
    file { "${logroot}/hhvm":
        ensure => directory,
        mode   => '0777',
    }

    file { $hhbc_dir:
        ensure => directory,
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0755',
    }

    file { $common_settings['hhvm']['repo']['central']['path']:
        ensure => file,
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0666',
    }

    file { $fcgi_settings['hhvm']['repo']['central']['path']:
        ensure => file,
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0644',
    }

    apache::site { 'hhvm_admin':
        ensure  => present,
        content => template('hhvm/admin-apache-site.erb'),
        require => Class['::apache::mod::proxy_fcgi'],
    }

    rsyslog::conf { 'hhvm':
        content  => template('hhvm/rsyslog.conf.erb'),
        priority => 40,
    }
}
