# == Class: role::articleplaceholder
# The ArticlePlaceholder extension
# Generates placeholders from Wikidata items
class role::articleplaceholder {
    include ::role::wikidata
    include ::role::scribunto

    mediawiki::extension { 'ArticlePlaceholder':
        needs_update => true,
    }

    mediawiki::settings { 'Wikidata allowEntityImport':
        wiki     => 'wikidata',
        values   => {
            "wgWBRepoSettings['allowEntityImport']" => true,
        },
        priority => $::load_later,
    }

    mediawiki::import::dump { 'ImportImageProperty':
        xml_dump           => '/vagrant/mediawiki/extensions/ArticlePlaceholder/includes/Template/Wikidata-P18.xml',
        dump_sentinel_page => 'Property:P18',
        db_name            => 'wikidatawiki',
        wiki               => 'wikidata',
    }

    mediawiki::import::dump { 'ImportModuleAndTemplate':
        xml_dump           => '/vagrant/mediawiki/extensions/ArticlePlaceholder/includes/Template/aboutTopic-template-module.xml',
        dump_sentinel_page => 'Module:AboutTopic',
    }
}
