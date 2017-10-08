#!/usr/bin/env bash

if ! which vagrant > /dev/null; then
    echo "Vagrant doesn't seem to be installed. Please download and install it"
    echo "from http://www.vagrantup.com/downloads.html and re-run setup.sh."
    exit 1
fi

vagrant config --required

echo
echo "You're all set! Simply run \`vagrant up\` to boot your new environment."
echo "(Or try \`vagrant config --list\` to see what else you can tweak.)"
