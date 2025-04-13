# == Class: php::remote_debug
# This class enables support for remote debugging of PHP code using
# Xdebug. Remote debugging allows you to interactively walk through your
# code as executes. Remote debugging is most useful when used in
# conjunction with a PHP IDE such as PhpStorm or Emacs (with Geben).
# The IDE is installed on your machine, not the Vagrant VM.
#
#
# This was formerly a role, but is now enabled on all
# MediaWiki-Vagrant installations.
#
# To use:
#
# -- In your IDE, enable "Start Listening for PHP Debug Connections"
# -- For Firefox, install
#    https://addons.mozilla.org/en-US/firefox/addon/the-easiest-xdebug
#    and click "Enable Debug" icon in the Add-on bar
# -- Set breakpoints
# -- Navigate to 127.0.0.1:8080/...
#
# See https://www.mediawiki.org/wiki/MediaWiki-Vagrant/Advanced_usage#MediaWiki_debugging_using_Xdebug_and_an_IDE_in_your_host
# for more information.
class php::remote_debug {
    package { 'php8.1-xdebug': }

    php::ini { 'remote_debug':
        settings => {
            'xdebug.discover_client_host' => true,
            'xdebug.log'                  => '/vagrant/logs/xdebug.log',
            'xdebug.log_level'            => 1,
            'xdebug.max_nesting_level'    => 200,
            # Is cover expected to be the default?
            # That is significantly slower, especially running tests
            'xdebug.mode'                 => 'debug',
        },
        require  => Package['php8.1-xdebug'],
    }
}
