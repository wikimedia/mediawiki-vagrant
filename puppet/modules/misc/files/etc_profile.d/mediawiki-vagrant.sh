#!/bin/sh

# silence 'stdin: not a tty' errors
sed -i -e "s/^mesg n/tty -s \&\& mesg n/" ~/.profile >/dev/null 2>&1

[ -z "$BASH_VERSION" -o -z "$PS1" ] && return

# handy aliases
alias ..="cd .."
alias ack=ack-grep

# enable color for the shell prompt (PS1)
export force_color_prompt="yes"

# set en_us.UTF-8 locale
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# check if there are updates available
commits=$(git --git-dir=/vagrant/.git rev-list HEAD...origin/master --right-only --count 2>/dev/null)
if [ -n "$commits" ] && [ "$commits" -gt 0 ]; then
    printf "Updates for MediaWiki-Vagrant are available. "
    printf "Run '$(tput bold; tput setaf 3)git pull --rebase$(tput sgr0)' in your Vagrant directory to get them.\n"
fi

# enable bash completion
. /usr/share/bash-completion/bash_completion >/dev/null 2>&1
