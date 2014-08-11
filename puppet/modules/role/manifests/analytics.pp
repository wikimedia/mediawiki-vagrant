# == Class: role::analytics
# Includes all analytics related roles:
# - hadoop
# - hive
# - oozie
# - pig
# - sqoop
# - hue
#
# NOTE!  To use this class, you must have the
# puppet-cdh git submodule available.  Run this command on your
# local machine make sure modules/cdh is cloned and up to date.
#
#    git submodule update --init
#
# To use Hadoop GUIs, you'll want to set up some extra Vagrant
# forwarded ports.  You'll also need more RAM allocated to Vagrant.
# Edit your .settings.yaml file and add:
#
#   vagrant_ram: 2048
#   forward_ports:
#     8888:  8888,    # Hue
#     8088:  8088,    # Hadoop Job GUI
#     50070: 50070,   # Hadoop NameNode GUI
#     11000: 11000    # Oozie
#
# ALSO!  If you are not planning on using Mediawiki for this
# vagrant instance, you should comment out the include mediawiki
# line in site.pp.  You'll end up installing much less stuff.
#
class role::analytics {
    include role::hadoop
    include role::hive
    include role::oozie
    # cdh::pig and cdh::sqoop are not parameterized so they
    # do not need their own role classes.
    include cdh::pig
    include cdh::sqoop
    include role::hue
}
