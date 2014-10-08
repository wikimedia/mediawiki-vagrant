module MediaWikiVagrant
  module SettingsDefiner
    def self.included(other)
      super

      class << other
        attr_accessor :definitions
      end

      other.extend(Macros)
      other.definitions ||= {}
    end

    private

    module Macros
      def define(&blk)
        class_exec(&blk)
      end

      def setting(name, params = {})
        self.definitions[name] = Setting.new(name).tap do |setting|
          params.each { |name, value| setting.send("#{name}=", value) }
        end
      end
    end
  end
end
