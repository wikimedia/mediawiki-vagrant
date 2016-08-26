# == Class: role::citoid
# Provisions Citoid, a MediaWiki extension which adds an auto-
# filled citation tool to VisualEditor using the citoid service.
class role::citoid {
    include ::role::zotero
    include ::citoid

    mediawiki::extension { 'Citoid':
        settings => {
            wgCitoidServiceUrl => "//{\$wgServer}:${::citoid::port}/api"
        }
    }
}
