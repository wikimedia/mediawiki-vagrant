# == Class: role::securepoll
# This role installs the SecurePoll extension and creates an additional wiki:
#
# _vote.wiki.local.wmftest.net_::
#   Wiki where voting happens. Sysops here can create polls.
#
class role::securepoll {
    require ::role::mediawiki

    require_package('gnupg')

    mediawiki::extension { 'SecurePoll':
        needs_update => true,
        settings     => template('role/securepoll/conf.php.erb'),
    }

    mediawiki::wiki { 'vote': }
}
