# == Class: rbenv::deps::suse
#
# This module manages rbenv dependencies for suse $::osfamily.
#
class rbenv::deps::suse {
  if ! defined(Package['binutils']) {
    package { 'binutils': ensure => installed }
  }

  if ! defined(Package['gcc']) {
    package { 'gcc': ensure => installed }
  }

  if ! defined(Package['make']) {
    package { 'make': ensure => installed }
  }

  if ! defined(Package['libopenssl-devel']) {
    package { 'libopenssl-devel': ensure => installed }
  }

  if ! defined(Package['zlib-devel']) {
    package { 'zlib-devel': ensure => installed }
  }
}
