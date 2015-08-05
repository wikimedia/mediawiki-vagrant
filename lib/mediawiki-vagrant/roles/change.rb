require 'mediawiki-vagrant/plugin_environment'
require 'mediawiki-vagrant/settings_plugin'

module MediaWikiVagrant
  module Roles
    # Abstract command for making changes to currently enabled roles.
    #
    class Change < Vagrant.plugin(2, :command)
      include PluginEnvironment
      include SettingsPlugin

      def self.synopsis
        "#{mode} a mediawiki-vagrant role"
      end

      def execute
        options = {
          provision: false,
        }

        opts = OptionParser.new do |o|
          subcommands = o.default_argv.first(2).join(' ')

          o.banner = "Usage: vagrant #{subcommands} <name> [<name2> <name3> ...] [-h | -p]"
          o.separator ''
          o.separator "  #{banner}"
          o.separator ''
          o.separator 'Options:'
          o.separator ''


          o.on('-p', '--provision', "Run 'vagrant provision' afterwards") do
            options[:provision] = true
          end
        end

        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, help: opts.help.chomp if argv.length < 1

        possible = possible_roles
        roles = argv.map(&:downcase)

        roles.each do |r|
          unless possible.include? r
            @env.ui.error role_error
            return 1
          end
        end

        roles = new_roles(roles)
        changes = @mwv.load_settings(roles) - @mwv.load_settings

        @mwv.update_roles(roles)

        if options[:provision]
          with_target_vms(nil, single_target: true) do |vm|
            if vm.state.id == :running
              @mwv.trigger_reload if changes.any?
              vm.action :provision
            else
              vm.action :up, provision_enabled: true
            end
          end
        else
          @env.ui.info 'Ok. Run `vagrant provision` to apply your changes.'
          describe_settings_changes(changes)
        end

        0
      end

      private

      def banner
        raise NotImplementedError
      end

      def new_roles(roles)
        raise NotImplementedError
      end

      def possible_roles
        raise NotImplementedError
      end

      def role_error(role)
        raise NotImplementedError
      end
    end
  end
end
