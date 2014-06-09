# == Define: ruby::version::user
#
# Use a given version of Ruby for all commands executed as the given user
# (unless some directory-level version takes precedence).
#
# === Examples
#
# Use the default version of Ruby when executing commands as the vagrant user.
#
#   ruby::version::user { 'vagrant': }
#
# Use the Ruby 2.2.0-dev when executing commands as the vagrant user.
#
#   ruby::version::user { 'vagrant': ruby => '2.2.0-dev' }
#
define ruby::version::user(
    $ruby = $ruby::default_version,
) {
    include ruby::version

    exec { "exec-rbenv-local-$title":
        command => "$rbenv::install_dir/bin/rbenv local $ruby",
        user => $title,
        require => Ruby::Ruby[$ruby],
    }
}
