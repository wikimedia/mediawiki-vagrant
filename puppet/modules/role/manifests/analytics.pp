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
    include ::apt

    # CDH packages are not yet packaged for Trusty.
    # In the meantime, we allow Vagrant Trusty to
    # install Precise packages.
    file { '/etc/apt/sources.list.d/wikimedia-precise.list':
        source => 'puppet:///files/apt/wikimedia-precise.list',
        notify => Exec['update_package_index'],
        before => Class['::role::hadoop'],
    }

    include ::role::hadoop
    include ::role::hive
    include ::role::oozie
    # cdh::pig and cdh::sqoop are not parameterized so they
    # do not need their own role classes.
    include ::cdh::pig
    include ::cdh::sqoop

    # Hue does not currently work with Trusty :(
    # Need to solve this error:
    #   File "/usr/lib/hue/build/env/lib/python2.7/site-packages/python_daemon-1.5.1-py2.7.egg/daemon/daemon.py", line 25, in <module>
    #     import resource
    #   ImportError: No module named resource
    # I think this has something to do with the fact that
    # this symlink is broken in Trusty:
    # /usr/lib/hue/build/env/lib/python2.7/config -> /usr/lib/python2.7/config
    #include ::role::hue
}
