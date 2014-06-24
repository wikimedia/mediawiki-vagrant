module MediaWikiVagrant
    # A MediaWiki-Vagrant setting.
    #
    # @attr_reader name [Symbol] Name of the setting.
    #
    # @attr description [String] Brief description of the setting
    # @attr help [String] Additional help text
    # @attr default [Object] Default value
    # @attr coercion [Proc] Used to process a given setting value
    # @attr internal [true, false] Whether the setting is only used internally
    # @attr value [Object] Current value
    #
    # @see Settings
    #
    class Setting
        attr_reader :name
        attr_accessor :description, :help, :default, :coercion, :internal

        def initialize(name, value = nil)
            @name = name
            @value = value
            @coercion = ->(_, new) { new }
        end

        alias internal? internal

        def set?
            !@value.nil?
        end

        def unset!
            @value = nil
        end

        def value
            @value.nil? ? default : @value
        end

        def value=(other)
            @value = @coercion.call(self, other)
        end
    end
end
