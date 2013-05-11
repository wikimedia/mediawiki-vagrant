# Alias for `phpsh` that ensures it is invoked with the MediaWiki
# codebase as its working directory.
#
# This file is managed by Puppet.
#

# Ensure that we're in an interactive bash session.
[ -z "$BASH_VERSION" -o -z "$PS1" ] && return
phpsh () {
  (
    cd $MW_INSTALL_PATH
    command phpsh "$@"
  )
}
