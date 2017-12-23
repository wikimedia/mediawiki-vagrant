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
#   For editable installs, the package will be available under
#   $path/src/$python_module.
#
# [*package*]
#   Pip package to install.  Default: $title
#
# [*python_module*]
#    Installed Python module name. This usually should match $package. If it
#    doesn't, specify this. This will be used to determine if the package is
#    already installed in the virtualenv.  Default: $title
#
# [*editable*]
#    Install package in editable mode (pip -e), ie. does a git clone into the
#    main venv folder instead of installing a subset of the files only into
#    ./lib. You probably need to use the 'package' parameter if you use this.
#    If the package parameter points to a local path, link to that source
#    rather than cloning the source into ${path}/src.
#    Default: false
#
define virtualenv::package (
    $path,
    $package       = $title,
    $python_module = $title,
    $editable      = false,
) {
    Virtualenv::Environment[$path] -> Virtualenv::Package[$title]

    if ( $editable ) {
        # pip -e does not install dependencies, so install as normal
        # package first, then replace with editable version
        exec { "pip_install_${python_module}_dependencies_in_${path}":
            command => "${path}/bin/pip install ${package}",
            cwd     => $path,
            unless  => "${path}/bin/python -c 'import ${python_module}'",
        }
        exec { "pip_install_${python_module}_editable_in_${path}":
            command     => "${path}/bin/pip install -e ${package}",
            cwd         => $path,
            refreshonly => true,
            subscribe   => Exec["pip_install_${python_module}_dependencies_in_${path}"],
        }
    } else {
        exec { "pip_install_${python_module}_in_${path}":
            command => "${path}/bin/pip install ${package}",
            cwd     => $path,
            unless  => "${path}/bin/python -c 'import ${python_module}'",
        }
    }
}
