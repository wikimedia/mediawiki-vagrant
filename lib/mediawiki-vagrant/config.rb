require "mediawiki-vagrant/plugin_environment"
require "mediawiki-vagrant/settings/definitions"
require "mediawiki-vagrant/settings_plugin"
require "optparse"

module MediaWikiVagrant
    # Provides a command-line interface for configuration of MediaWiki-Vagrant
    # settings.
    #
    class Config < Vagrant.plugin(2, :command)
        include PluginEnvironment
        include SettingsPlugin

        def self.synopsis
            "configures mediawiki-vagrant settings"
        end

        def execute
            options = {
                interactive: false,
                list: false,
                required: false,
                get: [],
                unset: [],
            }

            opts = OptionParser.new do |o|
                o.banner = "Usage: vagrant config [options] [name] [value]"
                o.separator ""
                o.separator "Options:"
                o.separator ""

                o.on("--all", "Configure all settings") do
                    options[:interactive] = true
                end

                o.on("--required", "Configure only required settings") do
                    options[:interactive] = true
                    options[:required] = true
                end

                o.on("--list", "List all settings") do
                    options[:list] = true
                end

                o.on("--get NAME", "Get a configured setting") do |name|
                    options[:get] << name
                end

                o.on("--unset NAME", "Remove a configured setting") do |name|
                    options[:unset] << name
                end
            end

            argv = parse_options(opts)
            return if !argv

            if options[:list]
                list_settings
            elsif options[:interactive]
                interactively_configure(options)
            elsif argv.length == 2
                configure_setting(*argv)
            elsif options[:get].any? || options[:unset].any?
                get_settings(options[:get])
                unset_settings(options[:unset])
            else
                @env.ui.error opts
                return 1
            end

            0
        end

        private

        # Configures the given setting with the given value.
        #
        def configure_setting(name, value)
            configure do |settings|
              settings.unset!(name)
              settings[name] = parse_setting(settings.setting(name), value)
            end
        end

        # Displays current values for the given settings.
        #
        def get_settings(names)
            configure do |settings|
                names.each do |name|
                    if setting = settings.setting(name)
                        @env.ui.info setting.value, :bold => setting.set?
                    end
                end
            end
        end

        # Wraps the given string according to the current screen width and
        # indents the resulting block of text to the given indentation level.
        #
        def indent(string, n)
            tabs = "\t" * n
            wrap = screen_width - (n * 8) - 1

            tabs + string.gsub(/(.{1,#{wrap}})(\s+|\Z)/, "\\1\n#{tabs}").rstrip
        end

        # Displays a series of prompts for user configuration of either all
        # defined or only required settings.
        #
        def interactively_configure(options)
            configure do |settings|
                scope = settings.select do |name, setting|
                    Settings.definitions.include?(name) && !setting.internal?
                end

                if options[:required]
                    scope = scope.reject { |_, setting| setting.default? || setting.set? }
                end

                scope.each do |name, setting|
                    @env.ui.info setting.description, :bold => true
                    @env.ui.info setting.help unless setting.help.nil?

                    value = setting_display_value(setting.value)

                    @env.ui.info name, :bold => true, :new_line => false

                    prompt = value.empty? ? "" : " [#{value}]"
                    prompt += ": "

                    input = @env.ui.ask(prompt).strip
                    @env.ui.info ""

                    if !input.empty?
                        setting.value = parse_setting(setting, input)
                    elsif setting.allows_empty?
                        setting.value = input.strip
                    end
                end
            end
        end

        # Lists all defined settings and their currently set values.
        #
        def list_settings
            Settings.definitions.reject { |_, setting| setting.internal? }.each do |name, setting|
                @env.ui.info "#{name}\t#{setting.description}", :bold => true
                @env.ui.info indent(setting.help, 2) unless setting.help.nil?
                @env.ui.info ""
            end
        end

        # Current width of the terminal.
        #
        def screen_width
            @screen_width ||= `tput cols`.chomp.to_i rescue 80
        end

        # Unsets the given settings.
        #
        def unset_settings(names)
            configure do |settings|
                names.each { |name| settings.unset!(name) }
            end
        end
    end
end

