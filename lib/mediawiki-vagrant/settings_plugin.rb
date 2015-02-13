require "mediawiki-vagrant/settings"
require "yaml"

module MediaWikiVagrant
  # Provides helpers for plugins that access .settings.yaml.
  #
  module SettingsPlugin
    protected

    # Configures .settings.yaml with the given block.
    #
    def configure(&blk)
      @mwv.configure_settings(&blk)
    end

    # Parses user input and returns a Ruby object. User input is expected
    # to be valid YAML.
    #
    def parse_setting(setting, input)
      YAML.parse(input).to_ruby
    rescue Psych::SyntaxError
      nil
    end

    # The given setting value, suitable for display during configuration.
    #
    def setting_display_value(value)
      value.to_yaml.lines.first.match(/^--- (.+)$/) { |m| m[1] } || ""
    end
  end
end
