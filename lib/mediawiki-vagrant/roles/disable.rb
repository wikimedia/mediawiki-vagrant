require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
  module Roles
    class Disable < Vagrant.plugin(2, :command)
      include PluginEnvironment

      def self.synopsis
        'disables a mediawiki-vagrant role'
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant roles disable <name> [<name2> <name3> ...] [-h]'
          o.separator ''
          o.separator '  Disable one or more optional roles.'
          o.separator ''
        end

        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, help: opts.help.chomp if argv.length < 1

        enabled = @mwv.roles_enabled
        argv.map(&:downcase).each do |r|
          if not enabled.include? r
            @env.ui.error "'#{r}' is not enabled."
            return 1
          end
        end
        @mwv.update_roles(enabled - @argv)
        @env.ui.info 'Ok. Run `vagrant provision` to apply your changes.'

        0
      end
    end
  end
end
