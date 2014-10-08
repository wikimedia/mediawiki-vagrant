require "mediawiki-vagrant/plugin_environment"
require "mediawiki-vagrant/settings/definitions"
require "mediawiki-vagrant/settings_plugin"
require "optparse"

module MediaWikiVagrant
  # Configures port forwarding from the host to the guest VM.
  #
  class ForwardPort < Vagrant.plugin(2, :command)
    include PluginEnvironment
    include SettingsPlugin

    def self.synopsis
      "configures port forwarding from the host to the guest VM"
    end

    def execute
      options = {
        list: false,
        remove: []
      }

      opts = OptionParser.new do |o|
        o.banner = "Usage: vagrant forward-port [options] [host-port guest-port [...]]"
        o.separator ""
        o.separator "Options:"
        o.separator ""

        o.on("-l", "--list", "List currently forwarded ports") do
          options[:list] = true
        end

        o.on("-r", "--remove PORT", "Remove forwarding for the given host port") do |port|
          options[:remove] << port
        end
      end

      argv = parse_options(opts)
      return if !argv

      if options[:list]
        list
      elsif options[:remove].any?
        remove(options[:remove].map(&:to_i))
      elsif argv.length == 2
        forward(*(argv.map(&:to_i)))
      else
        @env.ui.error opts
        return 1
      end

      0
    end

    private

    def forward(host_port, guest_port)
      configure do |settings|
        setting = settings.setting(:forward_ports)
        setting.value = {} unless setting.set?
        setting.value[guest_port] = host_port
      end

      @env.ui.info "Local port #{host_port} will now forward to your VM's port #{guest_port}"
      @env.ui.warn "You'll need to `vagrant reload` for this change to take effect"
    end

    def list
      @env.ui.info "Local port => VM's port"
      @env.ui.info "-----------------------"
      configure do |settings|
        settings[:forward_ports].each do |guest_port, host_port|
          @env.ui.info "#{host_port} => #{guest_port}"
        end
      end
    end

    def remove(ports)
      configure do |settings|
        setting = settings.setting(:forward_ports)
        setting.value.reject! { |guest, host| ports.include?(host) } if setting.set?
      end
    end
  end
end
