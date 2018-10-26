# == Class: role::growthexperiments
# Configures GrowthExperiments, a MediaWiki extension that contains experiments by the Growth team
#
class role::growthexperiments {
    require ::role::mediawiki

    mediawiki::extension { 'GrowthExperiments':
        settings => {
            'wgWelcomeSurveyEnabled' => true,
        },
    }
}
