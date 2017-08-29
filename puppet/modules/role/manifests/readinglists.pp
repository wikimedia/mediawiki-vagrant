# == Class: role::readinglists
# Installs the Reading Lists[1] extension which provides
# an API to manage private lists of pages.
#
# [1] https://www.mediawiki.org/wiki/Extension:ReadingLists
#
class role::readinglists {
    mediawiki::extension { 'ReadingLists':
        needs_update => true,
    }

    mediawiki::import::text { 'VagrantRoleReadingLists':
        content => template('role/readinglists/VagrantRoleReadingLists.wiki.erb'),
    }
}

