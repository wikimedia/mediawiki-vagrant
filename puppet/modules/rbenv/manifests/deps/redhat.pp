# == Class: rbenv::deps::redhat
#
# This module manages rbenv dependencies for redhat $::osfamily.
#
class rbenv::deps::redhat {
  if ! defined(Package['binutils']) {
    package { 'binutils': ensure => installed }
  }

  if ! defined(Package['gcc']) {
    package { 'gcc': ensure => installed }
  }

  if ! defined(Package['gcc-c++']) {
    package { 'gcc-c++': ensure => installed }
  }

  if ! defined(Package['make']) {
    package { 'make': ensure => installed }
  }

  if ! defined(Package['openssl-devel']) {
    package { 'openssl-devel': ensure => installed }
  }

  if ! defined(Package['readline-devel']) {
    package { 'readline-devel': ensure => installed }
  }

  if ! defined(Package['zlib-devel']) {
    package { 'zlib-devel': ensure => installed }
  }
}
