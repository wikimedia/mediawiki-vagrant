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
    include ::arcanist
    include ::mediawiki
    include ::postfix
    require ::misc
    require ::mwv
    require ::mysql
    require ::redis

    require_package('php-tidy')
    require_package('tidy')

    # mailutils depends on default MTA or any MTA.  This way we
    # explicitly install postfix, not relying on it happening to be the
    # default MTA.
    require_package('mailutils')
    Package['postfix'] -> Package['mailutils']
}
