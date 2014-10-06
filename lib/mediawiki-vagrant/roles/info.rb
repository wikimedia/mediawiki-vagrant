require 'mediawiki-vagrant/plugin_environment'
require 'rdoc'

module MediaWikiVagrant
  module Roles
    class Info < Vagrant.plugin(2, :command)
      include PluginEnvironment

      def self.synopsis
        'get information about a mediawiki-vagrant role'
      end

      def execute
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant roles info [<role> ...]'
          o.separator ''
          o.separator '  Describe a mediawiki-vagrant role.'
          o.separator ''
        end

        argv = parse_options(opts)
        return if !argv

        if argv.any?
          roles = argv.map(&:downcase)
          invalid_roles = roles - @mwv.roles_available

          if invalid_roles.any?
            invalid_roles.each { |role| @env.ui.error "'#{role}' is not a valid role." }
            return 1
          end
        else
          roles = @mwv.roles_available
        end

        rd = RDoc::Markup::ToAnsi.new

        roles.each do |role|
          if doc = @mwv.role_docstring(role)
            @env.ui.info rd.convert(doc)
          end
        end

        0
      end
    end
  end
end
