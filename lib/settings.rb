# -*- mode: ruby -*-
# vi: set ft=ruby :
#
# Simple settings management for customizing the Vagrantfile behavior

require 'yaml'

class Settings

    def initialize(defaults)
        @settings = {}
        update(defaults)
    end

    # Get a setting
    def [](key)
        @settings.fetch(key, nil)
    end

    # Load settings from a file
    def load(file)
        update(YAML.load_file(file)) if File.exists?(file)
    end

    # Update current settings with a new hash
    def update(other_settings)
        @settings.update(other_settings) do |key, oldval, newval|
            if key == 'FORWARD_PORTS'
                # Merge port mappings
                oldval.update(newval)

            elsif key == 'VAGRANT_RAM' || key == 'VAGRANT_CORES'
                # Keep the biggest ram and cores
                [oldval, newval].max

            else
                # New hotness trumps old busted
                newval
            end
        end
    end
end
