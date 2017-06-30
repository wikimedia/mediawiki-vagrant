#!/bin/bash
cd /srv/varnish-build/Varnish-Cache
./autogen.sh
./configure
make
make install