# MediaWiki-Vagrant bash completion
#
# Provide completion for custom commands provided by the MediaWiki-Vagrant
# plugin.
#
# Best used in combination with the excellent vagrant-bash-completion script
# from <https://kura.io/vagrant-bash-completion/>. Without the
# vagrant-bash-completion script, basic Vagrant commands will not be
# tab-completed.
#
# Install by copying this file to $BASH_COMPLETION_DIR/vagrant-mediawiki
#
_mw_vagrant_completion() {
  local commands="config forward-port git-update hiera import-dump paste-puppet roles run-tests"
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" == 1 ]; then
    COMPREPLY=( $(compgen -W "${commands}" -- "$word") )
    if [ "$(type -t _vagrant)" == "function" ]; then
      # Combine with default completion
      local SAVEREPLY=( "${COMPREPLY[@]}" )
      _vagrant
      COMPREPLY=( "${COMPREPLY[@]}" "${SAVEREPLY[@]}" )
    fi
    return 0

  else
    local words=("${COMP_WORDS[@]}")
    unset words[0]
    unset words[$COMP_CWORD]

    local vagrant_dir="$(_mw_vagrant_dir)"

    case "${words[1]}" in
      roles|config)
        if [ ! -z $vagrant_dir ] && [ -f "$vagrant_dir/support/completion.rb" ]; then
          local completions=$("$(_mw_vagrant_ruby)" -- "$vagrant_dir/support/completion.rb" "${words[@]}")
          COMPREPLY=( $(compgen -W "$completions" -- "$word") )
          return 0;
        fi
        ;;
    esac
  fi

  # Delegate to base vagrant completion if we can
  # (see https://github.com/kura/vagrant-bash-completion)
  [ "$(type -t _vagrant)" == "function" ] && _vagrant
}

# Heuristically resolve a good-enough Ruby (> 1.8).
#
_mw_vagrant_ruby() {
  if [ "$(uname)" == "Darwin" ]; then
    # System ruby on OS X should be good enough
    ruby=/usr/bin/ruby
  else
    # Try to use the bundled ruby on other systems
    ruby=/opt/vagrant/embedded/bin/ruby
  fi

  # Fallback to a system installed ruby (as long as it's 1.9 or above)
  if [ ! -x "$ruby" ]; then
    ruby="$(which ruby2.1 ruby2.0 ruby1.9.3 ruby1.9.1 ruby1.9 ruby | head -n 1 2> /dev/null)"
  fi

  echo $ruby
}

# Find the project directory (where Vagrantfile resides).
#
_mw_vagrant_dir() {
  local dir="${1:-$PWD}"

  if [ "$dir" == "/" ]; then
    return 1;
  elif [ -f "$dir/Vagrantfile" ]; then
    echo $dir
    return 0;
  else
    _mw_vagrant_dir "$(dirname "$dir")"
    return $?
  fi
}

complete -F _mw_vagrant_completion vagrant
