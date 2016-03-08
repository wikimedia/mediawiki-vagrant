# == Class: role::wikitech
#
# Provisions a MediaWiki instance similar to https://wikitech.wikimedia.org/.
#
class role::wikitech {
    include ::role::cite
    include ::role::codeeditor
    include ::role::echo
    include ::role::gadgets
    include ::role::parserfunctions
    include ::role::scribunto
    include ::role::wikieditor
    include ::role::wikilove

    # Alas, if only SMW didn't require composer
    # mediawiki::extension { [ 'SemanticForms', 'SemanticResultFormats' ]:
    #     needs_update  => true,
    #     require       => Mediawiki::Extension[ 'SemanticMediaWiki' ],
    # }
    #
    # mediawiki::extension { 'SemanticMediaWiki':
    #     needs_update  => true,
    #     require       => Mediawiki::Extension['Validator'],
    # }

    mediawiki::extension { 'LdapAuthentication':
        needs_update => true,
        settings     => template('role/wikitech/LdapAuth.php.erb'),
    }

    # General wiki settings, OSM config
    mediawiki::settings { 'WikitechLocalSettings':
        values  => template('role/wikitech/Local.php.erb'),
    }

    # Secret OSM passwords (will need to change on the fly for
    # OpenStack integration).
    mediawiki::settings { 'WikitechPrivateSettings':
        values  => template('role/wikitech/Private.php.erb'),
    }

    mediawiki::settings { 'WikitechDebugSettings':
        values  => template('role/wikitech/Debug.php.erb'),
    }

    mediawiki::extension { [
        'CategoryTree',
        'CheckUser',
        'Collection',
        'DynamicSidebar',
        'Nuke',
        'OATHAuth',
        'OpenStackManager',
        'Renameuser',
        'TitleBlacklist',
    ]:
        needs_update  => true,
    }

    mediawiki::import::dump { 'wikitech_content':
        xml_dump           => '/vagrant/puppet/modules/role/files/wikitech/initial-pages.xml',
        dump_sentinel_page => 'Shell_Request/Andrew',
    }
}
