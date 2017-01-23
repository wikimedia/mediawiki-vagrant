# == Class eventlogging::devserver
#
class eventlogging::devserver(
    $output_file = '/vagrant/logs/eventlogging.log',
) {
    require ::eventlogging

    # Local variable for ease of use in service.upstart.erb template.
    $eventlogging_path = $::eventlogging::path

    service { 'eventlogging-devserver':
        ensure    => 'present',
    }
}
