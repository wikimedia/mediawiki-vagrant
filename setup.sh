#!/usr/bin/env bash
#
# Executes setup.rb using the Ruby bundled with Vagrant.
#

if ! which vagrant > /dev/null; then
    echo "Vagrant doesn't seem to be installed. Please download and install it"
    echo "from http://www.vagrantup.com/downloads.html and re-run setup.sh."
    exit 1
fi

# These paths assume Vagrant was installed from the vendor-supplied packages
if [ "$(uname)" == "Darwin" ]; then
    ruby=/Applications/Vagrant/embedded/bin/ruby
else
    ruby=/opt/vagrant/embedded/bin/ruby
fi

# Try to fallback on a system-installed ruby (as long as it's 1.9 or above)
if [ ! -x "$ruby" ]; then
    ruby="$(which ruby2.1 ruby2.0 ruby1.9.3 ruby1.9.1 ruby1.9 ruby | head -n 1)"

    if [ $? -gt 0 ] || "$ruby" -e 'exit RUBY_VERSION < "1.9"'; then
        echo "A version of Ruby >= 1.9 isn't installed on your system and the"
        echo "version bundled with Vagrant couldn't be found."
        exit 2
    fi
fi

"$ruby" "$(dirname "$0")/support/setup.rb" "$0" "$@"
