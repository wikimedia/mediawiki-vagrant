# See https://www.mediawiki.org/wiki/MediaWiki-Vagrant/Advanced_usage#MediaWiki_debugging_using_Xdebug_and_an_IDE_in_your_host
# for more information.

# Each IDE has it's own default IDE key value (which can be overwritten manually if you need to).
# IDE | Default IDE Key Value
# Eclipse | 'XDEBUG_ECLIPSE'
# Netbeans | 'netbeans-xdebug'
# MacGDBPp | 'macgdbp'
# PHPStorm | 'PHPSTORM'
#
class php::xdebug {

    $pecl_installed = 'pecl list xdebug';

    exec { 'php_xdebug_install':
      command => 'pecl install xdebug',
      unless  => $pecl_installed,
      require => Package['php-pear']
    }

    # this should really be set using facter but currently we can only set custom facts
    # within the Vagrantfile, which isn't the right place for a manifest specific var
    $php_ext_path = inline_template("<%= `/usr/bin/php -r \"echo ini_get(\'extension_dir\');\" 2>/dev/null` %>")

    # make sure the xdebug log file exists
    file { '/vagrant/logs/xdebug.log':
      ensure => present,
      owner  => 'vagrant',
      group  => 'vagrant',
      mode   => '0644',
    }

    php::ini { 'xdebug':
      settings => {
          'zend_extension'             => "${php_ext_path}/xdebug.so",
          'xdebug.remote_connect_back' => 'On', # this only works with web requests, for cli see below
          'xdebug.remote_enable'       => 'On',
          'xdebug.idekey'              => 'PHPSTORM', # see top docbloc for different IDE defaults
          'xdebug.max_nesting_level'   => 200,
          'xdebug.remote_log'          => '/vagrant/logs/xdebug.log',

          # uncomment the below settings if you are debugging from the cli
          #'xdebug.remote_host' => '10.0.2.2', # https://developer.android.com/studio/run/emulator-networking.html
          #'xdebug.remote_autostart' => 'On' # this doesn't need to be on but it makes life easier on the cli
      }
    }

}
