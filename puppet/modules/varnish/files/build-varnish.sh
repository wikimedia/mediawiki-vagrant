#!/bin/bash
cd /tmp/Varnish-Cache
./autogen.sh
./configure
make
make install