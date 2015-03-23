require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
  class Reload < Vagrant.plugin('2', :provisioner)
    include PluginEnvironment

    def provision
      return unless @mwv.reload?
      @mwv.cancel_reload

      @machine.ui.warn 'Reloading vagrant...'

      @machine.action(:reload, {})
      sleep 0.5 until @machine.communicate.ready?

      @machine.ui.success 'Vagrant reloaded.'
    end
  end
end
