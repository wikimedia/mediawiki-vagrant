require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
  module Roles
    class List < Vagrant.plugin(2, :command)
      include PluginEnvironment

      def self.synopsis
        'lists available mediawiki-vagrant roles'
      end

      def execute
        opts = {}
        optparse = OptionParser.new do |o|
          o.banner = 'Usage: vagrant roles list [options]'
          o.separator ''
          o.separator '  List available roles.'
          o.separator ''
          o.separator 'Options:'

          opts[:enabled] = false
          o.on('-e', '--enabled', 'Only show enabled roles') do
            opts[:enabled] = true
          end

          opts[:single_col] = !interactive_out?
          o.on('-1', '--onecol', 'Single column output without header/footer') do
            opts[:single_col] = true
            opts[:verbose] = false
          end

          opts[:verbose] = interactive_out?
          o.on('-q', '--quiet', 'Suppress output of headers and footers') do
            opts[:verbose] = false
          end

          o.on_tail('-h', '--help', 'Display this help screen') do
            @env.ui.info o
            exit
          end
        end

        return unless parse_options(optparse)

        if opts[:enabled]
          show_enabled(opts)
        else
          show_all(opts)
        end

        0
      end

      def show_enabled(opts)
        @env.ui.info "Enabled roles:\n" if opts[:verbose]
        roles = @mwv.roles_enabled

        if opts[:single_col]
          roles.each { |x| @env.ui.info x }
        else
          print_cols(roles)
        end
      end

      def show_all(opts)
        @env.ui.info "Available roles:\n" if opts[:verbose]
        enabled = @mwv.roles_enabled

        roles = @mwv.roles_available.sort.map do |role|
          prefix = enabled.include?(role) ? '*' : ' '
          "#{prefix} #{role}"
        end

        if opts[:single_col]
          roles.each { |x| @env.ui.info x }
        else
          print_cols(roles)
        end

        if opts[:verbose]
          @env.ui.info "\nRoles marked with '*' are enabled."
          @env.ui.info 'Note that roles enabled by dependency are not marked.'
          @env.ui.info 'Use `vagrant roles enable` & `vagrant roles disable` to customize.'
        end

        0
      end

      def print_cols(roles)
        if roles.any?
          col, *cols = roles.each_slice((roles.size/3.0).ceil).to_a
          col.zip(*cols) do |a,b,c|
            @env.ui.info sprintf('%-26s %-26s %-26s', a, b, c)
          end
        end
      end
    end
  end
end
