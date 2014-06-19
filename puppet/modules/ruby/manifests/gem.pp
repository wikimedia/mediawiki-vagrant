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
# Make sure Nokogiri is installed for Ruby 1.9.3.
#
#   ruby::gem { 'nokogiri': ruby => '1.9.3' }
#
# Make sure a version of Nokogiri greater than 1.0 is installed for Ruby 1.9.3.
#
#   ruby::gem { 'nokogiri': version => '> 1.0', ruby => '1.9.3' }
#
define ruby::gem(
    $gem     = $title,
    $ruby    = $ruby::default_version,
    $version = '>=0',
) {
    include ruby

    exec { "gem-install-${gem}-${ruby}-${version}":
        command => "gem${ruby} install ${gem} --version '${version}'",
        unless  => "gem${ruby} list ${gem} --installed --version '${version}'",
        timeout => 600,
        require => Package["ruby${ruby}"],
    }
}
