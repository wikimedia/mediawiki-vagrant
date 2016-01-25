# == Class: role::gettingstarted
# Configures the GettingStarted extension and its dependencies:
# EventLogging and GuidedTour. GettingStarted adds a special page which
# presents introductory content and tasks to newly-registered editors.
# CirrusSearch is used for its 'morelike' feature, so recommendations
# can be provided based on textual similarity.  PageImages is used
# to provide thumbnails of articles in the recommendations.
class role::gettingstarted {
    include ::role::cirrussearch
    include ::role::eventlogging
    include ::role::guidedtour
    include ::role::pageimages

    mediawiki::extension { 'GettingStarted':
        browser_tests => true,
        settings      => {
            wgGettingStartedRedis                  => '127.0.0.1',
            # A sample category configuration for local testing.
            wgGettingStartedCategoriesForTaskTypes => {
                copyedit => 'Category:All_articles_needing_copy_edit',
                clarify  => 'Category:All_Wikipedia_articles_needing_clarification',
                addlinks => 'Category:All_articles_with_too_few_wikilinks',
            },
            wgGettingStartedExcludedCategories     => ['Category:Living people'],
        },
    }
}
