require 'mediawiki-vagrant/plugin_environment'
require 'mediawiki-vagrant/settings/definitions'
require 'mediawiki-vagrant/settings_plugin'

module MediaWikiVagrant
  # Opens the VM in a browser
  #
  class Open < Vagrant.plugin(2, :command)
    include PluginEnvironment
    include SettingsPlugin

    def self.synopsis
      'Opens the wiki in a browser'
    end

    def execute
      open
      0
    end

    private

    def open
      with_target_vms(nil, single_target: true) do |vm|
        vm.action :up, provision_enabled: true if vm.state.id != :running
        configure do |settings|
          # shamelessly OS-specific
          fork do
            exec 'xdg-open', "http://dev.wiki.local.wmftest.net:#{settings[:http_port]}",
              out: File::NULL, err: File::NULL
          end
        end
      end
    end
  end
end
