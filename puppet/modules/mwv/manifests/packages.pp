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
        'ruby-dev',
    )

    # Cron resources need a cron provider installed
    Package['anacron'] -> Cron <| |>

    # Remove chef if it is installed in the base image
    # Bug: 67693
    package { [ 'chef', 'chef-zero' ]:
      ensure => absent,
    }
}
