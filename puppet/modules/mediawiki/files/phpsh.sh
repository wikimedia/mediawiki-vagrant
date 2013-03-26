# Ensure that we're in an interactive bash session.
[ -z "$BASH_VERSION" -o -z "$PS1" ] && return
phpsh () {
  (
    cd /vagrant/mediawiki
    command phpsh "$@"
  )
}
