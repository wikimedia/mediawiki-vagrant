# == Class: rbenv::deps
#
# This module manages rbenv dependencies and should *not* be called directly.
#
# === Authors
#
# Justin Downing <justin@downing.us>
#
# === Copyright
#
# Copyright 2013 Justin Downing
#
class rbenv::deps {
  include ::git

  case $::osfamily {
    'Debian': {
      include rbenv::deps::debian
      $group = 'adm'
    }
    'RedHat': {
      include rbenv::deps::redhat
      $group = 'wheel'
    }
    'Suse': {
      include rbenv::deps::suse
      $group = 'users'
    }
    default:  { fail('The rbenv module currently only suports Debian, RedHat, and Suse families') }
  }
}
