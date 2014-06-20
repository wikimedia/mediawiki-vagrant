class role::wikitech {
    include role::mediawiki


#    Alas, if only SMW didn't require composer
#    mediawiki::extension { [ 'SemanticForms', 'SemanticResultFormats' ]:
#        needs_update  => true,
#        require       => Mediawiki::Extension[ 'SemanticMediaWiki' ],
#    }
#
#    mediawiki::extension { 'SemanticMediaWiki':
#        needs_update  => true,
#        require       => Mediawiki::Extension['Validator'],
#    }
#

    mediawiki::extension { 'LdapAuthentication':
        needs_update => true,
        settings     => template('wikitech/LdapAuth.php.erb'),
    }

    # General wiki settings, OSM config
    mediawiki::settings { 'WikitechLocalSettings':
        values  => template('wikitech/Local.php.erb'),
    }

    # Secret OSM passwords (will need to change on the fly for OpenStack integration)
    mediawiki::settings { 'WikitechPrivateSettings':
        values  => template('wikitech/Private.php.erb'),
    }

    mediawiki::settings { 'WikitechDebugSettings':
        values  => template('wikitech/Debug.php.erb'),
    }

    include role::cite
    include role::codeeditor
    include role::echo
    include role::gadgets
    include role::parserfunctions
    include role::scribunto
    include role::wikilove
    include role::wikieditor

    mediawiki::extension { [ 'CategoryTree',
                             'CheckUser',
                             'Collection',
                             'DynamicSidebar',
                             'Nuke',
                             'OATHAuth',
                             'OpenStackManager',
                             'Renameuser',
                             'TitleBlacklist',
                             'Vector']:
        needs_update  => true,
    }

    mediawiki::import_dump { 'wikitech_content':
        require            => Class['::role::mediawiki'],
        xml_dump           => '/vagrant/puppet/modules/wikitech/files/wikitech-initial-pages.xml',
        dump_sentinel_page => 'Testwiki:wiki/Wikimedia_Labs',
    }
}
