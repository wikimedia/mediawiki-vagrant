module VagrantVbguest
  module Helpers
    module VmCompatible
      def communicate
        vm.channel
      end

      def driver
        vm.driver
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def vm_id(vm)
          vm.uuid
        end

        def communicate_to(vm)
          vm.channel
        end

        def distro_name(vm)
          vm.guest.distro_dispatch
        end
      end
    end
  end
end
