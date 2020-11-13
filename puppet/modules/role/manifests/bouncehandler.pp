# == Class: role::bouncehandler
# Installs the BounceHandler[https://www.mediawiki.org/wiki/Extension:BounceHandler]
# extension which allows wikis to handle bounce emails efficiently.
#
class role::bouncehandler {
    include ::postfix
    include ::role::mediawiki

    mediawiki::extension { 'BounceHandler':
        needs_update => true,
    }

    File<|title == '/etc/postfix/virtual'|> {
        content => template('role/bouncehandler/virtual.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }
    File<|title == '/etc/postfix/aliases'|> {
        content => template('role/bouncehandler/aliases.erb'),
        owner   => 'root',
        group   => 'root',
        mode    => '0444',
    }
}

