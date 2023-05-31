# == Class: role::quicksurveys
#
# Installs the QuickSurveys[https://www.mediawiki.org/wiki/Extension:QuickSurveys]
# extension which shows simple, low-friction in-article surveys.
#
class role::quicksurveys {
    include role::eventlogging

    mediawiki::extension { 'QuickSurveys':
        needs_update => true,
        settings     => {
            wgQuickSurveysConfig => [
            ]
        }
    }
}
