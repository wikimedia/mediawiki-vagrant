# == Class: role::payments
# Provision a payments wiki using the fundraising deployment branch.
#
# This role creates one additional wiki, payments.wiki.local.wmftest.net
#
class role::payments {
  require ::role::mediawiki
  require ::role::memcached

  include ::payments
}
