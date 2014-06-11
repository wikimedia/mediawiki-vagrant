# == Define: ruby::version::directory
#
# Use a given version of Ruby for all commands executed below the given
# directory.
#
# === Examples
#
# Use the default version of Ruby when executing commands in the
# /some/project directory.
#
#   ruby::version::directory { '/some/project': }
#
# But use Ruby 2.2.0-dev when executing commands beneath the its embed
# subdirectory.
#
#   ruby::version::directory { '/some/project/embed': ruby => '2.2.0-dev' }
#
define ruby::version::directory(
    $ruby = $ruby::default_version,
) {
    include ruby::version

    # While this could be done by executing `rbenv local`, simply creating the
    # file seems less error prone, not to mention the format is not specific
    # to rbenv
    file { "${title}/.ruby-version":
        content => $ruby,
        require => Ruby::Ruby[$ruby],
    }
}
