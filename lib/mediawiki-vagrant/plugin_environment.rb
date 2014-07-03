require 'mediawiki-vagrant/environment'

module MediaWikiVagrant
    module PluginEnvironment
        def initialize(*args)
            super
            @mwv = Environment.new(@env.root_path)
        end
    end
end
