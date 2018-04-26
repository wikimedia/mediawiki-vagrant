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
    Package['anacron'] -> Cron <| |>

    # Remove chef if it is installed in the base image
    # Bug: 67693
    package { [ 'chef', 'chef-zero' ]:
        ensure => absent,
    }
}
