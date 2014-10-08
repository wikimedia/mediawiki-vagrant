module MediaWikiVagrant
  module LsbCheck
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :vendor
      attr_accessor :version

      def initialize
        @vendor = UNSET_VALUE
        @version = UNSET_VALUE
      end

      def finalize!
        @vendor = 'Ubuntu' if @vendor == UNSET_VALUE
        @version = nil if @version == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors
        if !version
          errors << '`version` must be set.'
        end
        { 'lsb_check provisioner' => errors }
      end
    end
  end
end

