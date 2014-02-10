# == Class: role::generic
# Configures common tools and shell enhancements.
class role::generic {
    include ::apt
    include ::env
    include ::git
    include ::misc
}
