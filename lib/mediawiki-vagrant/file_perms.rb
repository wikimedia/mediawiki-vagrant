require 'fileutils'

require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
  class FilePerms < Vagrant.plugin('2', :provisioner)
    include PluginEnvironment

    def configure(_root_config)
      # T183150: Make cache/apt/partial world writable
      FileUtils.chmod 'a=wrx', @mwv.path('cache/apt/partial')
    end
  end
end
