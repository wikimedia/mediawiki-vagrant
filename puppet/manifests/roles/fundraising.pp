# == Class: role::fundraising
#
# Provision subsystems being developed by the Fundraising group
#
class role::fundraising {
    include role::mysql
    include ::activemq
    include ::crm

    vagrant::settings { 'fundraising':
        # apache-activemq is a memory-slurping Java zombie.
        ram => 2048,
    }

    include packages::rsyslog

    $rsyslog_max_message_size = '64k'

    service { 'rsyslog':
        ensure     => running,
        provider   => 'init',
        require    => Package['rsyslog'],
        hasrestart => true,
    }
}
