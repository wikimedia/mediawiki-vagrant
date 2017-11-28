# == Class eventlogging::devserver
#
class eventlogging::devserver(
    $output_file = '/vagrant/logs/eventlogging.log',
) {
    require ::eventlogging

    # Local variable for ease of use in service.upstart.erb template.
    $eventlogging_path = $::eventlogging::path
    file { '/etc/init/eventlogging-devserver.conf':
        content => template('eventlogging/devserver.upstart.erb'),
    }

    service { 'eventlogging-devserver':
        ensure    => 'running',
        enable    => true,
        provider  => 'upstart',
        subscribe => [
            File['/etc/init/eventlogging-devserver.conf'],
        ],
    }
}
