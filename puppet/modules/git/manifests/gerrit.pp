# == Class: git::gerrit
#
# Provision ssh configuration for access to gerrit.wikimedia.org
#
class git::gerrit {

    sshkey { 'gerrit.wikimedia.org':
        ensure => 'present',
        key    => 'AAAAB3NzaC1yc2EAAAADAQABAAAAgQCF8pwFLehzCXhbF1jfHWtd9d1LFq2NirplEBQYs7AOrGwQ/6ZZI0gvZFYiEiaw1o+F1CMfoHdny1VfWOJF3mJ1y9QMKAacc8/Z3tG39jBKRQCuxmYLO1SWymv7/Uvx9WQlkNRoTdTTa9OJFy6UqvLQEXKYaokfMIUHZ+oVFf1CgQ==',
        type   => 'ssh-rsa',
    }

    # https://tickets.puppetlabs.com/browse/PUP-2900
    file { '/etc/ssh/ssh_known_hosts':
        ensure => 'present',
        owner  => 'root',
        group  => 'root',
        mode   => '0644',
    }

    if $::git_user {
        exec { 'gitreview.username':
            command     => "/usr/bin/git config --global --add gitreview.username '${::git_user}'",
            environment => [
                'HOME=/home/vagrant',
            ],
            user        => 'vagrant',
            unless      => '/usr/bin/git config --global gitreview.username',
            require     => Package['git'],
        }
    }

    Sshkey <| |> -> File['/etc/ssh/ssh_known_hosts']
}
