module MediaWikiVagrant
  module SettingsDefiner
    def self.included(other)
      super

      class << other
        def definitions
          @definitions_hash.each.with_object({}) do |(key, setting), hash|
            hash[key] = setting.dup
          end
        end

        protected

        attr_reader :definitions_hash
      end

      other.class_exec { @definitions_hash ||= {} }
      other.extend(Macros)
    end

    private

    module Macros
      def define(&blk)
        class_exec(&blk)
      end

      def setting(name, params = {})
        self.definitions_hash[name] = Setting.new(name).tap do |setting|
          params.each { |name, value| setting.send("#{name}=", value) }
          setting.freeze
        end
      end
    end
  end
end
