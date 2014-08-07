# == Class: role::fundraising
#
# Provision subsystems being developed by the Fundraising group
#
class role::fundraising {
    include role::centralnotice
    include role::mysql

    include ::activemq
    include ::crm

    require_package('rsyslog')

    # apache-activemq is a memory-slurping Java zombie.
    vagrant::settings { 'fundraising': ram => 2048, }


    $rsyslog_max_message_size = '64k'

    service { 'rsyslog':
        ensure     => running,
        provider   => 'init',
        hasrestart => true,
        require    => Package['rsyslog'],
    }
}
