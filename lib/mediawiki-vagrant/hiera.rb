require "mediawiki-vagrant/plugin_environment"
require "optparse"

module MediaWikiVagrant
    # Provides a command-line interface for configuration of hiera settings.
    #
    class Hiera < Vagrant.plugin(2, :command)
        include PluginEnvironment

        def self.synopsis
            "configures hiera settings"
        end

        def execute
            options = {
                unset: [],
            }

            opts = OptionParser.new do |o|
                o.banner = "Usage: vagrant hiera [options] [key] [value]"
                o.separator ""
                o.separator "Options:"
                o.separator ""

                o.on("--unset NAME", "Remove a configured key") do |name|
                    options[:unset] << name
                end
            end

            argv = parse_options(opts)
            return if !argv

            if options[:unset].any?
                unset_key(options[:unset])
            elsif argv.length == 2
                set_key(*argv)
            else
                @env.ui.error opts
                return 1
            end

            0
        end

        private

        # Configures the given key with the given value.
        #
        def set_key(name, value)
          @mwv.hiera_set(name, value)
        end

        # Unsets the given keys.
        #
        def unset_key(names)
          names.each { |name| @mwv.hiera_delete(name) }
        end
    end
end

