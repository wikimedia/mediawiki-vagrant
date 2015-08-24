require 'rdoc'

require 'mediawiki-vagrant/plugin_environment'
require 'mediawiki-vagrant/settings_plugin'

module MediaWikiVagrant
  module Roles
    class Info < Vagrant.plugin(2, :command)
      include PluginEnvironment
      include SettingsPlugin

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

        settings = @mwv.load_settings

        roles.each do |role|
          doc = @mwv.role_docstring(role)
          @env.ui.info rd.convert(doc) if doc

          changes = @mwv.load_settings(@mwv.roles_enabled + [role]) - settings

          if changes.any?
            @env.ui.warn 'Enabling this role will adjust the following settings:'

            changes.each do |setting, change|
              cur, new = *change.map { |v| setting_display_value(v) }

              @env.ui.info ''
              @env.ui.info setting.description unless setting.description.nil?
              @env.ui.info "#{setting.name}: #{cur} -> ", new_line: false
              @env.ui.info "#{new}", bold: true
            end
          end
        end

        0
      end
    end
  end
end
