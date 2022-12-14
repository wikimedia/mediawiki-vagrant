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
      # Only supports Unix now. Probably Mac could use 'open' instead of
      # 'xdg-open' and Windows could use 'start' but somebody needs to test it.
      unless Vagrant::Util::Platform.linux?
        @env.ui.warn "'vagrant open' is only implemented for Linux at the moment."
        return 1
      end
      with_target_vms(nil, single_target: true) do |vm|
        vm.action :up, provision_enabled: true if vm.state.id != :running
        configure do |settings|
          fork do
            exec 'xdg-open', "http://dev.wiki.local.wmftest.net:#{settings[:http_port]}",
              out: File::NULL, err: File::NULL
          end
        end
      end
    end
  end
end
