# == Class: mwv::packages
#
class mwv::packages {
    package { [
        'python-pip',
        'python-setuptools',
        'python-wheel',
    ]: } -> Package <| provider == pip |>

    # Install common packages
    require_package(
        'anacron',
        'build-essential',
        'cron',
        'gdb',
        'python-dev',
        'python3-dev',
        'python3-pip',
        'python3-setuptools',
        'python3-wheel',
        'ruby-dev',
        'tzdata',
    )

    # T184497: NFS client packages are needed to use NFS shares, and if they
    # are not already in the VM the auto-provisioning that Vagrant tries to do
    # will fail after our first Puppet run because of the things we do that
    # mess with the default apt cache location.
    require_package(
        'nfs-common',
        'rpcbind',
    )

    # Cron resources need a cron provider installed
    Package['anacron', 'cron'] -> Cron <| |>

    # Remove chef if it is installed in the base image
    # Bug: 67693
    package { [ 'chef', 'chef-zero' ]:
        ensure => absent,
    }

    # T164126 logrotate messes up its status time over time, which leads to
    # logs eating up all space and breaking the box. Logrotate 3.12+, coming
    # in Debian Buster, will fix that; until then, just do a test rotation
    # periodically and delete the logrotate status file on error (which does
    # not cause problems other than making low-frequency logs rotate a bit
    # faster than intended).
    cron { 'delete_logrotate_status':
        command => '/usr/sbin/logrotate --debug /etc/logrotate.conf 2> /dev/null || /bin/rm /var/lib/logrotate/status',
        user    => 'root',
        # run frequently - the VM is probably not up all day
        minute  => 0,
    }
}
