# == Class: role::gettingstarted
# Configures the GettingStarted extension and its dependencies:
# EventLogging and GuidedTour. GettingStarted adds a special page which
# presents introductory content and tasks to newly-registered editors.
class role::gettingstarted {
    include role::mediawiki
    include role::eventlogging
    include role::guidedtour

    mediawiki::extension { 'GettingStarted':
        settings => {
            wgGettingStartedRedis => '127.0.0.1',
        },
    }
}
