#!/bin/bash
cd /srv/varnish-build/libvmod-tbf
./bootstrap
./configure VARNISHSRC=/srv/varnish-build/Varnish-Cache VMODDIR=/usr/local/lib/varnish/vmods
make
make install