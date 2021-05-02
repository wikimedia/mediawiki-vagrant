require 'mediawiki-vagrant/plugin_environment'
require 'optparse'

module MediaWikiVagrant
  # Provides a command-line interface for configuration of hiera settings.
  #
  class Hiera < Vagrant.plugin(2, :command)
    include PluginEnvironment

    def self.synopsis
      'sets and displays hiera overrides'
    end

    def execute
      options = {
        unset: [],
      }

      opts = OptionParser.new do |o|
        o.banner = 'Usage: vagrant hiera [options] [key] [value]'
        o.separator ''
        o.separator 'Options:'
        o.separator ''

        o.on('--unset NAME', 'Remove a configured key') do |name|
          options[:unset] << name
        end
      end

      argv = parse_options(opts)
      return unless argv

      if options[:unset].any?
        unset_key(options[:unset])
      elsif argv.length == 2
        set_key(*argv)
      elsif argv.length == 1
        get_key(*argv)
      else
        @env.ui.error opts
        return 1
      end

      0
    end

    private

    # Print the value of the given key
    #
    def get_key(name)
      @env.ui.info @mwv.hiera_get(name)
    end

    # Configures the given key with the given value.
    #
    def set_key(name, value)
      # Let yaml coerce the provided value to a native type
      # This is especially useful for booleans and numbers
      @mwv.hiera_set(name, YAML.load(value))
    end

    # Unsets the given keys.
    #
    def unset_key(names)
      names.each { |name| @mwv.hiera_delete(name) }
    end
  end
end
