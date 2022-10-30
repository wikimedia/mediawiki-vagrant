# == Class: role::phan
# phan requires a significant amount memory to run, more than the default.
# Performance is increased significantly using the php-ast extension.
class role::phan {
    require_package('php7.4-ast')
}
