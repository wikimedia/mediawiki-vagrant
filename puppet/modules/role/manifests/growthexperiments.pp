# == Class: role::growthexperiments
# Configures GrowthExperiments, a MediaWiki extension that contains experiments by the Growth team
#
class role::growthexperiments {
    require ::role::mediawiki
    include ::role::pageviewinfo

    mediawiki::extension { 'GrowthExperiments':
        settings => template('role/growthexperiments/conf.php.erb'),
    }
}
