# == Class: mailcatcher
#
# Installs Mailcatcher for viewing email sent from within the vm.
# Inbox should be visible at: http://localhost:1080/
#
# To simplfy usage, a mailcatcher service has been added so the standard
# `sudo service mailcatcher start|stop|status` calls are available.
#
# Note:
# Currently PHP(sendmail) and postfix messages are captured.
# For help configuring other backends see https://github.com/sj26/mailcatcher#how
#
class mailcatcher {

    include ::postfix
    include ::ruby

    # install sqlite
    require_package('libsqlite3-dev')

    # install mailcatcher
    package {'mailcatcher':
        ensure   => 'installed',
        provider => 'gem'
    }

    # add mailcatcher service
    systemd::service { 'mailcatcher':
      ensure  => present,
      require => Package['mailcatcher'],
    }

    # add php config
    php::ini { 'mailcatcher':
      settings => {
          'sendmail_path' => '/usr/bin/env catchmail -f some@from.address'
      },
      require  => Package['mailcatcher'],
    }

    # redirect postfix messages to mailcatcher
    File<|title == '/etc/postfix/transport'|> {
      content => template('mailcatcher/postfix.transport.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0444',
      require  => Package['mailcatcher']
    }

}
