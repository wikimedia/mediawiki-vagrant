# == Class: role::eventlogging
# This role sets up the EventLogging extension for MediaWiki such that
# events are validated against production schemas but logged locally.
class role::eventlogging {
    include ::role::geshi
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
    include ::apache::mod::headers

    # Define a 'ELDevServer' parameter for Apache <IfDefine> checks.
    apache::def { 'ELDevServer': }

    mediawiki::extension { 'EventLogging':
        priority => $::LOAD_EARLY,
        settings => {
            wgEventLoggingBaseUri => '//localhost:8080/event.gif',
            wgEventLoggingFile    => '/vagrant/logs/eventlogging.log',
        }
    }
}
