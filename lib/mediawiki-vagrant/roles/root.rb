require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
  module Roles
    class Root < Vagrant.plugin(2, :command)

      def self.synopsis
        'manage mediawiki-vagrant roles: list, enable, disable, etc.'
      end

      def initialize(argv, env)
        super

        @args, @command, @sub_args = split_main_and_subcommand(argv)

        @subcommands = Vagrant::Registry.new
        @subcommands.register(:list) do
          require_relative 'list'
          List
        end
        @subcommands.register(:reset) do
          require_relative 'reset'
          Reset
        end
        @subcommands.register(:enable) do
          require_relative 'enable'
          Enable
        end
        @subcommands.register(:disable) do
          require_relative 'disable'
          Disable
        end
        @subcommands.register(:info) do
          require_relative 'info'
          Info
        end
      end

      def execute
        return help if @args.include?('-h') || @args.include?('--help')

        command_class = @subcommands.get(@command.to_sym) if @command
        return help if !command_class || !@command

        command_class.new(@sub_args, @env).execute
      end

      def help
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant roles <command> [<args>]'
          o.separator ''
          o.separator 'Available subcommands:'

          commands = {}
          longest = 0
          @subcommands.each do |key, klass|
            key           = key.to_s
            commands[key] = klass.synopsis
            longest       = key.length if key.length > longest
          end

          commands.keys.sort.each do |key|
            o.separator "    #{key.ljust(longest + 1)} #{commands[key]}"
          end

          o.separator ''
          o.separator 'For help on any individual command run `vagrant roles COMMAND -h`'
        end
        @env.ui.info(opts.help, prefix: false)
      end
    end
  end
end
