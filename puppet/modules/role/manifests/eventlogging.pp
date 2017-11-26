# == Class: role::eventlogging
# This role sets up the EventLogging extension for MediaWiki such that
# events are validated against production schemas but logged locally.
class role::eventlogging {
    include ::role::syntaxhighlight
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
    include ::apache::mod::headers

    # Define a 'ELDevServer' parameter for Apache <IfDefine> checks.
    # This proxies :8080/event.gif to :8100/event.gif.
    apache::def { 'ELDevServer': }

    # Set up the eventlogging-devserver.
    # This listens for events at :8100/event.gif and writes valid events to
    # /vagrant/logs/eventlogging.log.
    include ::eventlogging::devserver

    mediawiki::extension { 'EventLogging':
        priority => $::load_early,
        settings => {
            wgEventLoggingBaseUri => '/event.gif',
        }
    }
}
