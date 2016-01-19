#!/bin/bash
cd /tmp/libvmod-tbf
./bootstrap
./configure VARNISHSRC=/tmp/Varnish-Cache VMODDIR=/usr/local/lib/varnish/vmods
make
make install