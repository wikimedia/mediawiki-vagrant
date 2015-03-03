# == Class: role::mediawiki
# Provisions a MediaWiki instance powered by HHVM, MySQL, and redis.
#
# === Parameters
# [+hostname+]
#   Hostname for the main wiki.
#
class role::mediawiki(
    $hostname,
){
    require ::apt
    include ::arcanist
    require ::env
    require ::git
    require ::misc
    require ::mysql
    require ::redis
    include ::mediawiki

    require_package('php5-tidy')
    require_package('tidy')
}
