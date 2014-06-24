require 'yaml'

require 'mediawiki-vagrant/setting'
require 'mediawiki-vagrant/settings_definer'

module MediaWikiVagrant
    # A collection of MediaWiki-Vagrant settings that can be loaded from and
    # written to a YAML-serialized file.
    #
    # Predefined settings can be declared using {.define} and given additional
    # options such as default values, descriptions to be used by interactive
    # prompts, and value coercion to enforce minimums, maximums, etc.
    #
    # @example Define settings
    #   Settings.define do
    #     setting :vagrant_ram,
    #       description: "Amount (in MB) of memory allocated to the VM",
    #       help: "Specify more memory for hungry tasks like browser tests",
    #       default: 1024,
    #       coercion: ->(setting, value) { [setting.default, value].max }
    #
    # @example Load settings from a file
    #   settings = Settings.new
    #   settings.load("file/path.yaml")
    #
    # @example Load settings from all .yaml files in a directory
    #   settings = Settings.new
    #   settings.load("settings.d")
    #
    # @example Change a setting and save to a file
    #   settings = Settings.new
    #   settings[:vagrant_ram] = 2048
    #   settings.save("file/path.yaml")
    #
    # @see Setting
    # @see SettingsDefiner
    # @see {file:settings/definitions.rb}
    #
    class Settings
        include Enumerable
        include SettingsDefiner

        # Safely configure the settings stored in the given file using the
        # provided block. The file is locked for exclusive write access during
        # evaluation.
        #
        # @param path [String] Path to settings file.
        #
        def self.configure(path)
            settings = Settings.new

            File.open(path, File::RDWR | File::CREAT) do |file|
                file.flock(File::LOCK_EX)

                begin
                    settings.load(file)
                    file.rewind

                    yield settings

                    file.truncate(settings.save(file))
                    file.flush
                ensure
                    file.flock(File::LOCK_UN)
                end
            end
        end

        def initialize
            @settings = self.class.definitions.clone
        end

        # The given setting's current value.
        #
        def [](key)
            key = normalize_key(key)

            @settings[key] && @settings[key].value
        end

        # Changes the given setting's value.
        #
        def []=(key, value)
            key = normalize_key(key)

            if @settings.include?(key)
                @settings[key].value = value
            else
                @settings[key] = Setting.new(key, value)
            end
        end

        # Iterate over each setting.
        #
        # @yield [name, setting]
        #
        def each(&blk)
            @settings.each(&blk)
        end

        # Load YAML-serialized settings from the given path. If a directory is
        # given, all files matching *.yaml are loaded.
        #
        # @param path_or_io [String, IO] Path to file, open IO, or directory
        #
        def load(path_or_io)
            case path_or_io
            when IO
                update(YAML.load(path_or_io))
            else
                if File.directory?(path_or_io)
                    Dir.glob("#{path_or_io}/*.yaml").each { |f| load(f) }
                else
                    load(File.new(path_or_io))
                end
            end
        end

        # Returns only those of the current settings that are required (have
        # no default value).
        #
        # @return [Hash]
        #
        def required
            select { |name, setting| setting.default.nil? }
        end

        # Serializes and saves the current settings to the given file path.
        #
        # @param path_or_io [String, #write] File path or open IO object.
        #
        # @return [Integer] Number of bytes written.
        #
        def save(path_or_io)
            yaml = YAML.dump(to_yaml_hash)

            case path_or_io
            when IO
                path_or_io.write(yaml)
            else
                File.open(path_or_io, 'w') { |f| f.write(yaml) }
            end
        end

        # Returns the setting with the given name.
        #
        # @param name [String, Symbol] Setting name
        #
        # @return [Setting]
        #
        def setting(name)
            @settings[normalize_key(name)]
        end

        # Updates settings from the given `{ name: value }` hash.
        #
        # @param other [Hash]
        #
        def update(other)
            other.each { |key, value| self[key] = value } if other.is_a?(Hash)
            self
        end

        # Unset the given setting.
        #
        # @param name [String] Setting name.
        #
        def unset!(name)
            (s = setting(name)) && s.unset!
        end

        private

        def normalize_key(key)
            key.to_s.downcase.to_sym
        end

        def to_yaml_hash(options = {})
            @settings.each.with_object({}) do |(key, setting), hash|
                hash[key.to_s] = setting.value if setting.value != setting.default
            end
        end
    end
end
