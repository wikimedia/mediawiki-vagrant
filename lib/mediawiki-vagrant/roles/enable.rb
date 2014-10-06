require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
  module Roles
    class Enable < Vagrant.plugin(2, :command)
      include PluginEnvironment

      def self.synopsis
        'enables a mediawiki-vagrant role'
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant roles enable <name> [<name2> <name3> ...] [-h]'
          o.separator ''
          o.separator '  Enable an optional role (run `vagrant roles list` for a list).'
          o.separator ''
        end

        argv = parse_options(opts)
        return if !argv
        raise Vagrant::Errors::CLIInvalidUsage, help: opts.help.chomp if argv.length < 1

        avail = @mwv.roles_available
        argv.map(&:downcase).each do |r|
          if not avail.include? r
            @env.ui.error "'#{r}' is not a valid role."
            return 1
          end
        end
        @mwv.update_roles(@mwv.roles_enabled + @argv)
        @env.ui.info 'Ok. Run `vagrant provision` to apply your changes.'

        0
      end
    end
  end
end
