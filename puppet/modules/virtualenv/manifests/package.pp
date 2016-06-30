# == Define virtualenv::package
# Installs a package using pip in the already created virtualenv.
#
# == Usage
# virtualenv::environment { '/path/to/my/virtualenv': }
#
# virtualenv::package { 'mysqlclient': path => '/path/to/my/virtualenv' }
#
# == Parameters
# [*path*]
#   Path to already previously initialized virtualenv.
#
# [*package*]
#   Pip package to install.  Default: $title
#
# [*python_module*]
#    Installed Python module name. This usually should match $package. If it
#    doesn't, specify this. This will be used to determine if the package is
#    already installed in the virtualenv.  Default: $title
#
define virtualenv::package (
    $path,
    $package        = $title,
    $python_module  = $title,
) {
    Virtualenv::Environment[$path] -> Virtualenv::Package[$title]

    exec { "pip_install_${package}_in_${path}":
        command => "${path}/bin/pip install ${package}",
        cwd     => $path,
        unless  => "${path}/bin/python -c 'import ${python_module}'",
    }
}
