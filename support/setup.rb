# Cross-platform setup script for MediaWiki-Vagrant.
#

$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'mediawiki-vagrant/setup'

begin
  setup = MediaWikiVagrant::Setup.new(ARGV.shift)
  setup.run
rescue OptionParser::InvalidOption => e
  STDERR.puts e
  STDERR.puts setup.options
rescue MediaWikiVagrant::Setup::ExecutionError => e
  STDERR.puts e
  exit e.status.exitstatus
end
