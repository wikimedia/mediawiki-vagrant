# == Class: php::sessionclean
#
# Ubuntu 14.04 ships with a script to clean up stale PHP session files that
# can under certain circumstances hang indefinitely or consume
# a dispropotionate amount of system resources. This class backports a newer
# version of the cleanup script from the Debian upstream which has not yet
# been backported to Ubunutu 14.04.
#
# === Parameters:
# [*ensure*]
#   Whether the files should exist. Possible values 'present', 'absent'.
#
class php::sessionclean(
    $ensure,
) {
    if !($ensure in ['present', 'absent']) {
        fail('ensure parameter must be present or absent.')
    }

  file { '/usr/lib/php5/sessionclean':
      ensure => $ensure,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
      source => 'puppet:///modules/php/sessionclean',
  }

  file { '/etc/cron.d/php5':
      ensure => $ensure,
      owner  => 'root',
      group  => 'root',
      mode   => '0644',
      source => 'puppet:///modules/php/php5.cron.d',
  }
}
