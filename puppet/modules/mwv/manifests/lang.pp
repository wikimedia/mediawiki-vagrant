# Class: mwv::lang
#
# Ensures the en_US.UTF-8 language exists.
#
class mwv::lang {
    exec { 'create en_US.UTF-8 language':
        command => 'echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && locale-gen',
        unless  => 'locale -a | grep en_US.UTF-8',
    }
}
