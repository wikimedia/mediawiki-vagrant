# vim:set sw=4 ts=4 sts=4 et:

# == Class: smtplog
#
# Provisions a python service that will listen on port 25 for SMTP connections
# and log the messages delivered to a file. This is useful for debugging email
# output from various applications without worrying about actually sending
# emails to the outside world.
#
# [*log_file*]
#   File to write log messages to
#
class smtplog(
    $log_file,
){
    file { '/etc/init/smtplog.conf':
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => template('smtplog/smtplog.conf.erb'),
    }

    service { 'smtplog':
        ensure   => running,
        provider => 'upstart',
        require  => File['/etc/init/smtplog.conf'],
    }
}
