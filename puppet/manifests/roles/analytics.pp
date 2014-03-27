# == Class: role::analytics
# Includes all analytics related roles:
# - hadoop
# - hive
#
# NOTE!  To use this and other analytics classes, you must have the
# puppet-cdh4 git submodule available.  Run this command on your
# local machine make sure modules/dh4 is cloned and up to date.
#
#    git submodule update --init
#
# You'll also need more RAM!  Edit Vagrantfile and increase --memory.
# 2048 M should be enough, but you can probably get away with less.
class role::analytics {
    include role::generic
    include role::hadoop
    include role::hive
}
