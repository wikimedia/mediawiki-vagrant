#!/usr/bin/env bash
# Build a fresh Mediawiki-Vagrant installer image
#
# Meant to be executed inside the Vagrant virtual machine
#
# Requires:
#   - aptitude
#   - genisoimage

MWV=/vagrant
CONTENTS=${MWV}/support/packager/output/contents

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
sudo aptitiude dist-upgrade
# Get rid of obsolete apt packages
sudo aptitude autoclean

# Hack some things into the build
mkdir -p ${CONTENTS}

# Add a BUILD_INFO file so we can tell what was included in the image
BUILD_INFO=${CONTENTS}/BUILD_INFO
echo "Build date: $(date +%Y-%m-%dT%H:%MZ)" >${BUILD_INFO}
echo "MediaWiki-Vagrant: $(cd ${MWV}; git rev-parse HEAD)" >>${BUILD_INFO}
echo "MediaWiki: $(cd ${MWV}/mediawiki; git rev-parse HEAD)" >>${BUILD_INFO}

# Populate apt cache
mkdir -p ${CONTENTS}/cache/apt/partial
rm -rf ${CONTENTS}/cache/apt/*.deb
(cd /vagrant/cache/apt/archives; tar cf - *.deb) |
(cd ${CONTENTS}/cache/apt; tar xf -)

# Generate installer output (directory and iso)
cd ${MWV}/support/packager
ruby package.rb

# Compute and store a checksum for the image
cd ${MWV}/support/packager/output
sha1sum mediawiki-vagrant-installer.iso > mediawiki-vagrant-installer.iso.SHA1.txt
