# == Class: mwv::packages
#
class mwv::packages {
    package { 'python-pip': } -> Package <| provider == pip |>

    # Install common development tools
    require_package('build-essential', 'python-dev', 'ruby-dev')

    # Remove chef if it is installed in the base image
    # Bug: 67693
    package { [ 'chef', 'chef-zero' ]:
      ensure => absent,
    }
}
