require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
  module Roles
    class Reset < Vagrant.plugin(2, :command)
      include PluginEnvironment

      def self.synopsis
        'disables all optional mediawiki-vagrant roles'
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant roles reset [-h]'
          o.separator ''
          o.separator '  Disable all optional roles.'
          o.separator ''
        end

        argv = parse_options(opts)
        return if !argv

        @mwv.update_roles []
        @env.ui.warn 'All roles were disabled.'
        @env.ui.info 'Ok. Run `vagrant provision` to apply your changes.'

        0
      end
    end
  end
end
