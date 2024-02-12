# == Class: docker
#
# Install Docker.
#
class docker {
    apt::repository { 'docker':
        uri        => 'https://download.docker.com/linux/debian',
        dist       => $::lsbdistcodename,
        components => stable,
        keyfile    => 'puppet:///modules/docker/docker-archive-keyring.asc',
        source     => false,
    }

    package { ['docker-ce', 'docker-buildx-plugin']:
        ensure  => present,
        require => Apt::Repository['docker'],
    }

    group { 'docker':
        ensure => present,
    }
    exec { 'www-data docker membership':
        unless  => '/usr/bin/groups www-data | /bin/grep -q "\bdocker\b"',
        command => '/usr/sbin/usermod -aG docker www-data',
        user    => 'root',
        require => Group['docker'],
    }
    exec { 'vagrant docker membership':
        unless  => '/usr/bin/groups vagrant | /bin/grep -q "\bdocker\b"',
        command => '/usr/sbin/usermod -aG docker vagrant',
        user    => 'root',
        require => Group['docker'],
    }
}
