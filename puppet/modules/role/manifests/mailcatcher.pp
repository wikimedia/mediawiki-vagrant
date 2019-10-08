# == Class: role::mailcatcher
#
# This role installs mailcatcher.
#
# MailCatcher runs a super simple SMTP server which catches
# any message sent to it and displays them in a web ui here:
# http://127.0.0.1:1080
#
class role::mailcatcher {
    include ::mailcatcher
    mediawiki::import::text { 'VagrantRoleMailcatcher':
        source => 'puppet:///modules/role/mailcatcher/VagrantRoleMailcatcher.wiki',
    }
}
