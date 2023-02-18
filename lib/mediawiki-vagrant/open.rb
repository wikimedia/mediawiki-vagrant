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
          if Vagrant::Util::Platform.linux?
            fork do
              exec 'xdg-open', "http://dev.wiki.local.wmftest.net:#{settings[:http_port]}",
                out: File::NULL, err: File::NULL
            end
          elsif Vagrant::Util::Platform.darwin?
            fork do
              exec 'open', "http://dev.wiki.local.wmftest.net:#{settings[:http_port]}",
                out: File::NULL, err: File::NULL
            end
          elsif Vagrant::Util::Platform.windows?
            # fork doesn't work on Windows, so we use spawn
            spawn 'start', "http://dev.wiki.local.wmftest.net:#{settings[:http_port]}",
              out: File::NULL, err: File::NULL
          else
            @env.ui.warn "'vagrant open' is not implemented for your platform."
            return 1
          end
        end
      end
    end
  end
end
