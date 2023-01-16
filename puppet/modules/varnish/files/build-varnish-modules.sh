#!/bin/bash
PREFIX=/usr/local
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
export ACLOCAL_PATH=$PREFIX/share/aclocal
cd /srv/varnish-build/varnish-modules
./bootstrap
./configure
make CFLAGS="-g -O2 -Wno-pointer-compare" check
make CFLAGS="-g -O2 -Wno-pointer-compare" install
