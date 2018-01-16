# == Class eventlogging::devserver
#
class eventlogging::devserver(
    $output_file = '/vagrant/logs/eventlogging.log',
) {
    require ::eventlogging

    # Local variable for ease of use in service.upstart.erb template.
    $eventlogging_path = $::eventlogging::path

    systemd::service { 'eventlogging-devserver':
        ensure             => 'present',
        epp_template       => true,
        template_variables => {
            'eventlogging_path' => $eventlogging_path,
            'output_file'       => $output_file,
        },
    }
}
