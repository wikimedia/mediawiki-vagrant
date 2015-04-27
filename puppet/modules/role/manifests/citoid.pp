# == Class: role::citoid
# Configures Citoid, a MediaWiki extension which adds an auto-
# filled citation tool to VisualEditor using the citoid service
# (not installed by this mainfest).
class role::citoid {
    include ::role::visualeditor

    mediawiki::extension { 'Citoid':
        settings => {
            wgCitoidServiceUrl => 'http://citoid.wikimedia.org/api'
        }
    }
}
