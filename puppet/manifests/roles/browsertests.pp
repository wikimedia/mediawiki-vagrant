# == Class: role::browsertests
# Configures this machine to run the Wikimedia Foundation's set of
# Selenium browser tests for MediaWiki instances.
class role::browsertests {
    include role::mediawiki

    class { '::browsertests': }
}
