# == Class: role::readinglists
# Installs the ReadingLists[https://www.mediawiki.org/wiki/Extension:ReadingLists]
# extension which provides an API to manage private lists of pages.
#
class role::readinglists {
    mediawiki::extension { 'ReadingLists':
        needs_update => true,
    }

    mediawiki::import::text { 'VagrantRoleReadingLists':
        content => template('role/readinglists/VagrantRoleReadingLists.wiki.erb'),
    }
}

