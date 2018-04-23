# == Class: role::mtail
# Installs an mtail instance
#
class role::mtail (
) {
    include ::mtail

    mtail::program { 'kernel':
        ensure => present,
        source => 'puppet:///modules/mtail/programs/kernel.mtail',
    }
}
