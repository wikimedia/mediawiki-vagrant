module MediaWikiVagrant
  # A MediaWiki-Vagrant setting.
  #
  # @attr_reader name [Symbol] Name of the setting.
  #
  # @attr description [String] Brief description of the setting
  # @attr help [String] Additional help text
  # @attr default [Object] Default value
  # @attr auto [Proc] Used to automatically configure the setting
  # @attr coercion [Proc] Used to process a given setting value
  # @attr internal [true, false] Whether the setting is only used internally
  # @attr allows_empty [true, false] Whether to allow empty string values
  # @attr value [Object] Current value
  #
  # @see Settings
  #
  class Setting
    attr_reader :name
    attr_accessor :description, :help, :default, :auto, :coercion, :internal, :allows_empty

    def initialize(name, value = nil)
      @name = name
      @value = value
      @coercion = ->(_, new) { new }
      @internal = false
      @allows_empty = false
    end

    alias allows_empty? allows_empty

    def auto!
      self.value = @auto.call unless @auto.nil? || set?
    end

    alias internal? internal

    def default?
      !@default.nil?
    end

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
      other = @auto.call if @auto && other == 'auto'
      @value = @coercion.call(self, other)
    end
  end
end
