# == Class: role::mleb
# The MediaWiki language extension bundle (MLEB) provides an easy way to bring
# ultimate language support to your MediaWiki. This role will install latest
# Universal Language Selector(ULS), Translate, Localisation Update, Clean
# Changes, Babel and CLDR MediaWiki extensions. What's more, Interwiki will be
# installed and configured so that MediaWiki can show the cross wiki link on
# the left sidebar.
class role::mleb {
    include role::mediawiki
    include role::cldr

    mediawiki::extension { 'Babel':
        require  => Mediawiki::Extension['cldr'],
    }

    mediawiki::extension { 'LocalisationUpdate':
        settings => {
            wgLocalisationUpdateDirectory => '$IP/cache',
        },
    }

    mediawiki::extension { 'CleanChanges':
        settings => [
            '$wgDefaultUserOptions["usenewrc"] = 1',
        ],
    }

    mediawiki::extension { 'Translate':
        needs_update => true,
        settings     => [
            '$wgGroupPermissions["*"]["translate"] = true',
            '$wgGroupPermissions["sysop"]["pagetranslation"] = true',
            '$wgGroupPermissions["sysop"]["translate-manage"] = true',
            '$wgTranslateDocumentationLanguageCode = "qqq"',
            '$wgExtraLanguageNames["qqq"] = "Message documentation"',
        ],
    }

    mediawiki::extension { 'Interwiki':
        settings => [ '$wgGroupPermissions["sysop"]["interwiki"] = true' ],
    }

    mediawiki::extension { 'UniversalLanguageSelector':
        settings => {
            wgULSEnable => true,
        },
        require  => Mediawiki::Extension['Interwiki'],
    }
}
