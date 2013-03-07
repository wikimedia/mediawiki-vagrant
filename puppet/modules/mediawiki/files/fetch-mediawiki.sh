#!/usr/bin/env bash
if [ ! -f "/vagrant/mediawiki/index.php" ]; then
	wget -O /tmp/mediawiki-latest.zip http://integration.mediawiki.org/nightly/mediawiki/core/mediawiki-latest.zip
	mediawiki=$(unzip -l mediawiki-latest.zip | grep -Eo 'mediawiki-\w{7}' | head -1)
	unzip /tmp/master.zip -d/tmp
	rm -f "/tmp/${mediawiki}/.gitignore"
	mv "/tmp/${mediawiki}/*" "/vagrant/mediawiki"
fi
