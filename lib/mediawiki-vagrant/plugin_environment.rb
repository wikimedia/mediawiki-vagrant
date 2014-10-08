require 'mediawiki-vagrant/environment'

module MediaWikiVagrant
  module PluginEnvironment
    def initialize(*args)
      super
      @mwv = Environment.new(@env.root_path || @env.cwd)
    end
  end
end
