# == Define: ruby::gem
#
# Declare a gem that should be installed for the given version of Ruby.
#
# === Parameters
#
# [*gem*]
#   The name of the gem, in case you need to scope the title. Default: $title.
#
# [*ruby*]
#   The version of Ruby for which to install the gem. Default:
#   $ruby::default_version.
#
# [*version*]
#   A specific version requirement for the gem. Default: '>=0'.
#
# === Examples
#
# Make sure Nokogiri is installed for the default version of Ruby.
#
#   ruby::gem { 'nokogiri': }
#
# Make sure Nokogiri is installed for Ruby 2.1.2.
#
#   ruby::gem { 'nokogiri': ruby => '2.1.2.' }
#
# Make sure a version of Nokogiri greater than 1.0 is installed for Ruby 2.1.2.
#
#   ruby::gem { 'nokogiri': version => '> 1.0', ruby => '2.1.2' }
#
define ruby::gem(
    $gem     = $title,
    $ruby    = $ruby::default_version,
    $version = '>=0',
) {
    include ruby

    rbenv::gem { "ruby-${ruby}-${gem}":
        gem          => $gem,
        ruby_version => $ruby,
        version      => $version,
        skip_docs    => true,
    }
}
