# == Class: mediawiki::ready_service
#
# Provisions a custom systemd unit that can be used to order other services
# which should not attempt to start until the base wiki is up and running. Use
# by both requiring and waiting for mediawiki-ready.service. The puppet
# manifest that provisions the service should require this class as well.
#
# === Example
#
#   [Unit]
#   Description=A service that should wait for MediaWiki to be up an running
#   Requires=mediawiki-ready.service
#   After=mediawiki-ready.service
#   [Service]
#   ...
#
class mediawiki::ready_service {
    include ::mediawiki

    file { '/usr/local/bin/wait-for-mediawiki.sh':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        content => template('mediawiki/wait-for-mediawiki.sh.erb'),
    }

    systemd::service { 'mediawiki-ready':
        ensure  => 'present',
        require => MediaWiki::Wiki[$::mediawiki::wiki_name],
    }
}
