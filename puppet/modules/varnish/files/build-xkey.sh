#!/bin/bash
PREFIX=/usr/local
export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig
export ACLOCAL_PATH=$PREFIX/share/aclocal
cd /tmp/libvmod-xkey
./autogen.sh
./configure
make
make install