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

    package { [
        'hhvm',
        'hhvm-dev',
        'hhvm-luasandbox',
        'hhvm-tidy',
        'hhvm-wikidiff2',
    ]:
        ensure => latest,
        notify => Service['hhvm'],
    }

    # T129343: Cleanup old hhvm-fss package if installed
    package { 'hhvm-fss':
        ensure => 'purged',
        before => Package['hhvm'],
    }

    # T129343: Ensure that config files are created before the HHVM package is
    # updated/installed. This reverses prior logic applied to fix T115450 but
    # is needed to cleanup the hhvm-fss package.
    File {
        before => Package['hhvm'],
    }

    env::alternative { 'hhvm_as_default_php':
        alternative => 'php',
        target      => '/usr/bin/hhvm',
        priority    => 20,
    }

    file { '/etc/hhvm':
        ensure => directory,
    }

    file { '/etc/hhvm/php.ini':
        content => php_ini($common_settings),
        before  => Env::Alternative['hhvm_as_default_php'],
    }

    file { '/etc/hhvm/fcgi.ini':
        content => php_ini($common_settings, $fcgi_settings),
        notify  => Service['hhvm'],
    }

    file { '/etc/default/hhvm':
        ensure  => file,
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
        content => template('hhvm/hhvm.default.erb'),
        notify  => Service['hhvm'],
    }

    file { '/etc/init/hhvm.conf':
        ensure => file,
        owner  => 'root',
        group  => 'root',
        mode   => '0444',
        source => 'puppet:///modules/hhvm/hhvm.conf',
        notify => Service['hhvm'],
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
        before => Env::Alternative['hhvm_as_default_php'],
    }

    file { $fcgi_settings['hhvm']['repo']['central']['path']:
        ensure => file,
        owner  => 'www-data',
        group  => 'www-data',
        mode   => '0644',
        before => Service['hhvm'],
    }

    service { 'hhvm':
        ensure   => running,
        enable   => true,
        provider => upstart,
        require  => File['/etc/init/hhvm.conf'],
    }

    apache::site { 'hhvm_admin':
        ensure  => present,
        content => template('hhvm/admin-apache-site.erb'),
        require => Class['::apache::mod::proxy_fcgi'],
    }

    rsyslog::conf { 'hhvm':
        content  => template('hhvm/rsyslog.conf.erb'),
        priority => 40,
        before   => Service['hhvm'],
    }
}
