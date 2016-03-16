# == Define: swift::container
#
# Creates and adds a swift container.
#
# === Parameters
#
# [*public*]
#   Whether the container should be publically readable.
#
# === Examples
#
#   swift::container { 'wiki-local-thumb':
#       public => true,
#   }
#
define swift::container(
    $public = false,
    $container = $title,
) {
    $port = $::swift::port
    $project = $::swift::project
    $user = $::swift::user
    $key = $::swift::key

    file { "/tmp/foo-${container}":
        ensure  => present,
        content => 'bar',
        mode    => '0644',
    }

    exec { "swift-create-container-${container}":
        command => "swift -A http://127.0.0.1:${port}/auth/v1.0 -U ${project}:${user} -K ${key} upload ${container} /tmp/foo-${container}",
        user    => 'root',
        unless  => "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:${port}/v1/AUTH_${project}/${container}/tmp/foo-${container} | grep -Pqv '404'",
        require => File["/tmp/foo-${container}"],
    }

    if ($public) {
        exec { "swift-make-container-public-${container}":
            command => "swift -A http://127.0.0.1:${port}/auth/v1.0 -U ${project}:${user} -K ${key} post -r '.r:*' ${container}",
            user    => 'root',
            require => Exec["swift-create-container-${container}"],
            unless  => "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:${port}/v1/AUTH_${project}/${container}/tmp/foo-${container} | grep -Pq '200'",
        }
    }
}