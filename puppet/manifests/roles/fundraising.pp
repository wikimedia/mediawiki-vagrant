# == Class: role::fundraising
#
# Provision subsystems being developed by the Fundraising group
#
class role::fundraising {
    include role::mysql
    include ::crm

    include packages::rsyslog

    $rsyslog_max_message_size = '64k'

    service { 'rsyslog':
        ensure     => running,
        provider   => 'init',
        require    => Package['rsyslog'],
        hasrestart => true,
    }
}
