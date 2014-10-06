require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
  module Roles
    class List < Vagrant.plugin(2, :command)
      include PluginEnvironment

      def self.synopsis
        'lists available mediawiki-vagrant roles'
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant roles list [-h]'
          o.separator ''
          o.separator '  List available roles.'
          o.separator ''
        end

        argv = parse_options(opts)
        return if !argv

        @env.ui.info "Available roles:\n"
        enabled = @mwv.roles_enabled

        roles = @mwv.roles_available.sort.map { |role|
          prefix = enabled.include?(role) ? '*' : ' '
          "#{prefix} #{role}"
        }
        col, *cols = roles.each_slice((roles.size/3.0).ceil).to_a
        col.zip(*cols) { |a,b,c|
          @env.ui.info sprintf("%-26s %-26s %-26s", a, b, c)
        }

        @env.ui.info "\nRoles marked with '*' are enabled."
        @env.ui.info 'Note that roles enabled by dependency are not marked.'
        @env.ui.info 'Use `vagrant roles enable` & `vagrant roles disable` to customize.'

        0
      end
    end
  end
end
