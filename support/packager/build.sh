#!/usr/bin/env bash
# Build a fresh Mediawiki-Vagrant installer image
#
# Meant to be executed inside the Vagrant virtual machine
#
# Requires:
#   - aptitude
#   - genisoimage

set -euf -o pipefail

MWV=/vagrant
CONTENTS=${MWV}/support/packager/output/contents
BUILD_INFO=${CONTENTS}/BUILD_INFO
APT_OPTS="-o Dpkg::Options::='--force-confdef' -o Dpkg::Options::='--force-confold' -y"
export DEBIAN_FRONTEND=noninteractive

{
    set -x

    # Get latest MediaWiki-Vagrant
    cd ${MWV}
    git fetch
    git reset --hard origin/master

    # Get latest MediaWiki-core
    export COMPOSER_CACHE_DIR="${MWV}/cache/composer"
    /usr/local/bin/run-git-update
    cd ${MWV}/mediawiki
    git reset --hard origin/master

    # Freshen git cache
    sudo apt-get update
    sudo apt-get $APT_OPTS dist-upgrade
    # Get rid of obsolete apt packages
    sudo apt-get $APT_OPTS autoclean

    # Hack some things into the build
    mkdir -p ${CONTENTS}

    # Add a BUILD_INFO file so we can tell what was included in the image
    echo "Build date: $(date +%Y-%m-%dT%H:%MZ)" >${BUILD_INFO}
    echo "MediaWiki-Vagrant: $(cd ${MWV}; git rev-parse HEAD)" >>${BUILD_INFO}
    echo "MediaWiki: $(cd ${MWV}/mediawiki; git rev-parse HEAD)" >>${BUILD_INFO}

    # Populate apt cache from local cache
    rsync -a --delete --include='*.deb' ${MWV}/cache/apt/ ${CONTENTS}/cache/apt
    mkdir -p ${CONTENTS}/cache/apt/partial
    # Ensure that we don't sneak a lock file into the cache clone
    rm -f ${CONTENTS}/cache/apt/lock

    # Generate installer output (directory and iso)
    cd ${MWV}/support/packager
    ruby package.rb

    # Compute and store a checksum for the image
    cd ${MWV}/support/packager/output
    sha1sum mediawiki-vagrant-installer.iso > mediawiki-vagrant-installer.iso.SHA1.txt

    echo "Done!"
} 2>&1
