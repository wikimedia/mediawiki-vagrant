# == Class: role::quicksurveys
#
# Installs the QuickSurveys[1] extension which shows simple, low-friction
# in-article surveys.
#
# [1] https://www.mediawiki.org/wiki/Extension:QuickSurveys
#
class role::quicksurveys {
    include role::eventlogging

    mediawiki::extension { 'QuickSurveys':
        needs_update => true,
    }
}
