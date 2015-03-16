# == Class: role::fundraising
#
# Provision subsystems being developed by the Fundraising group
#
class role::fundraising {
    include ::role::centralnotice
    include ::activemq
    include ::crm

    require_package('rsyslog')

    $rsyslog_max_message_size = '64k'

    service { 'rsyslog':
        ensure     => running,
        provider   => 'init',
        hasrestart => true,
        require    => Package['rsyslog'],
    }
}
