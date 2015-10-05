#!/bin/bash
cd /tmp/libvmod-xkey
./autogen.sh
./configure
make
make install