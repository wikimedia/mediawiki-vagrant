#!/bin/bash
# If there are unmerged upstream changes for MediaWiki-Vagrant, this script
# will tell you so and explain how to merge them.
#
# This file is managed by Puppet.
#
[ -z "$BASH_VERSION" -o -z "$PS1" ] && return

COMMITS=$(git --git-dir=/vagrant/.git rev-list HEAD...origin/master --right-only --count 2>/dev/null)
if [ -n "$COMMITS" ] && [ "$COMMITS" -gt 0 ]; then
    printf "Updates for MediaWiki-Vagrant are available. "
    printf "Run '$(tput bold; tput setaf 3)git pull$(tput sgr0)' in your Vagrant directory to get them.\n"
fi
