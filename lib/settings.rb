# -*- mode: ruby -*-
require 'yaml'

class Settings
    def initialize(defaults)
        @settings = {}
        update(defaults)
    end

    def [](key)
        @settings.fetch(key.downcase, nil)
    end

    def load(path)
        if File.directory?(path)
            Dir.glob("#{path}/*.yaml").each { |f| load(f) }
        else
            update(YAML.load_file(path))
        end
    end

    def update(other_settings)
        # downcase case for back-compat
        other_settings = Hash[other_settings.map{ |k,v| [k.downcase, v] }]
        @settings.update(other_settings) do |key, old, new|
            case key
            when 'forward_ports'
                old.update(new)
            when 'vagrant_ram', 'vagrant_cores'
                [old, new].max
            else
                new
            end
        end
    end
end
