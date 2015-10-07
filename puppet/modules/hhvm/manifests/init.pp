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
# HHVM is in the process of standardizing on the INI file format for
# configuration files. At the moment (Aug 2014) there are still some
# options that can only be set using the deprecated HDF syntax. This
# is why we have two configuration files for each SAPI.
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
class hhvm (
    $common_settings,
    $fcgi_settings,
    $logroot,
    $hhbc_dir,
    $docroot,
) {
    include ::apache
    include ::apache::mod::proxy_fcgi

    package { [
        'hhvm',
        'hhvm-dev',
        'hhvm-fss',
        'hhvm-luasandbox',
        'hhvm-tidy',
        'hhvm-wikidiff2',
    ]:
        ensure => latest,
        notify => Service['hhvm'],
    }

    env::alternative { 'hhvm_as_default_php':
        alternative => 'php',
        target      => '/usr/bin/hhvm',
        priority    => 20,
        # T114811: Don't make /usr/bin/php point to HHVM until the service has
        # started as the upstart script ensures that a needed symlink is in
        # place. There is still a race when the hhvm package is updated but
        # there's not a lot we can do about that.
        require     => Service['hhvm'],
    }

    file { '/etc/hhvm':
        ensure => directory,
    }

    file { '/etc/hhvm/php.ini':
        content => php_ini($common_settings),

        # @todo
        # remove force => true once the dpkg for hhvm is updated to create
        # its version of php.ini in /etc/hhvm/php.ini instead of in
        # /etc/hhvm/php.ini/php.ini
        #
        # @see https://phabricator.wikimedia.org/T87478
        force   => true,

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

    file { '/usr/local/bin/hhvmsh':
        source => 'puppet:///modules/hhvm/hhvmsh',
        mode   => '0555',
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

    # Clean up legacy config files
    file { [
      '/etc/hhvm/config.hdf',
      '/etc/hhvm/server.ini',
      '/etc/hhvm/fcgi',
      '/etc/hhvm/fcgi/php.ini',
      '/etc/hhvm/fcgi/config.hdf',
    ]:
        ensure => absent,
        force  => true,
    }
}
