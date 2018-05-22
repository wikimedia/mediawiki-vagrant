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
        settings     => {
            wgQuickSurveysConfig => [
                {
                    enabled         => true,
                    type            => 'internal',
                    name            => 'perceived-performance-survey',
                    question        => 'ext-quicksurveys-performance-internal-survey-question',
                    answers         => [
                        'ext-quicksurveys-example-internal-survey-answer-positive',
                        'ext-quicksurveys-example-internal-survey-answer-neutral',
                        'ext-quicksurveys-example-internal-survey-answer-negative',
                    ],
                    coverage        => 0.0,
                    platforms       => {
                        'desktop' => [
                            'stable',
                        ]
                    },
                    'privacyPolicy' => 'ext-quicksurveys-performance-internal-survey-privacy-policy',
                },
            ]
        }
    }
}
