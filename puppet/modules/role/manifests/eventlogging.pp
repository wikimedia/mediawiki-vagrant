# == Class: role::eventlogging
# This role sets up the EventLogging extension for MediaWiki such that
# events are validated against production schemas but logged locally.
# There is no backend (eventually the eventgate role will do that),
# log events can only be inspected in the browser.
class role::eventlogging {
    include ::role::syntaxhighlight
    include ::apache::mod::proxy
    include ::apache::mod::proxy_http
    include ::apache::mod::headers

    # Define a 'ELDevServer' parameter for Apache <IfDefine> checks.
    # This proxies :8080/event.gif to :8100/event.gif.
    apache::def { 'ELDevServer': }

    # In progress: We are moving away from the EventLogging server backend in favor of eventgate.
    # Include both eventlogging::devserver and eventgate modules during the migration.
    # Once production is moved to eventgate, we will remove inclusion eventlogging::devserver.
    # NOTE: Set npm::node_version: 10 in hiera
    $node_version = hiera('npm::node_version', undef)
    if (!$node_version or $node_version < 10) {
        warning('EventLogging role requires the EventGate service, which requires NodeJS 10. To use it, set npm::node_version: 10 in hieradata/common.yaml (Might break other services.)')
    }

    # EventLogging will produce to EventGate at wgEventLoggingServiceUri.
    include ::eventgate
    $eventgate_url = $::eventgate::url # Used in EventLogging.php.erb template.s

    mediawiki::extension { 'EventLogging':
        priority => $::load_early,
        settings => template('role/eventlogging/EventLogging.php.erb'),
    }

    mediawiki::extension { 'EventStreamConfig':
        priority => $::load_early,
    }
}
