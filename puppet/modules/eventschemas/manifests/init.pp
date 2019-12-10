# == Class eventschemas
#
class eventschemas(
    $service_root_dir = hiera('service::root_dir')
) {
    $path = "${service_root_dir}/schemas/event"

    file { ["${service_root_dir}/schemas", $path]:
        ensure => 'directory',
    }

    git::clone { 'schemas/event/primary':
        directory => "${path}/primary",
    }
    git::clone { 'schemas/event/secondary':
        directory => "${path}/secondary",
    }

    service::gitupdate { 'schemas-event-primary':
        dir => "${path}/primary",
    }
    service::gitupdate { 'schemas-event-secondary':
        dir => "${path}/secondary",
    }
}
