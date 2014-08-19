# == Class: role::mediawiki
# Provisions a MediaWiki instance powered by PHP, MySQL, and redis.
#
# === Parameters
#
# [*hostname*]
#   Hostname for the main wiki.
#
class role::mediawiki(
    $hostname,
){
    include ::apt
    include ::env
    include ::git
    include ::misc
    include ::mysql
    include ::redis
    include ::mediawiki

    require_package('php5-tidy')
    require_package('tidy')
}
