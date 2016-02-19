# == Class eventschemas
#
class eventschemas {
    $path = "${::service::root_dir}/event-schemas"

    git::clone { 'mediawiki/event-schemas':
        directory => $path,
    }

    service::gitupdate { 'event-schemas': }
}
