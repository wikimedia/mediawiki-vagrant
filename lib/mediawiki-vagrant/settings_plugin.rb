require 'yaml'

require 'mediawiki-vagrant/settings'
require 'mediawiki-vagrant/settings/definitions'

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

    # Describe the changes to settings that will occur.
    #
    def describe_settings_changes(changes)
      return unless changes.any?

      @env.ui.info ''
      @env.ui.warn 'Note the following settings have changed and your environment will be reloaded.'

      changes.each do |setting, change|
        cur, new = *change.map { |v| setting_display_value(v) }
        @env.ui.info "#{setting.name}: #{cur} -> ", new_line: false
        @env.ui.info new, bold: true
      end

      @mwv.trigger_reload
    end

    # Parses user input and returns a Ruby object. User input is expected
    # to be valid YAML.
    #
    def parse_setting(setting, input)
      YAML.load(input)
    rescue Psych::SyntaxError
      nil
    end

    # The given setting value, suitable for display during configuration.
    #
    def setting_display_value(value)
      if value.is_a?(Hash) && value.any?
        "{ #{value.to_yaml.sub(/^---/, '').strip.gsub(/\r?\n/m, ', ')} }"
      else
        value.to_yaml.lines.first.match(/^--- (.+)$/) { |m| m[1] } || ''
      end
    end
  end
end
