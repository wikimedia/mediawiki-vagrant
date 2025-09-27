module MediaWikiVagrant
  module AptFix
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def provision
        # T405845: Fix bullseye-backports URL
        execute_inline <<-end_
          set -e
          sudo sed -i 's!https://deb.debian.org/debian bullseye-backports!https://archive.debian.org/debian bullseye-backports!g' /etc/apt/sources.list
        end_
      end

      private

      def execute_inline(script)
        @machine.communicate.tap do |comm|
          comm.execute("cat <<'EOF' | /usr/bin/env bash\n#{script}\nEOF", error_class: Error)
        end
      end
    end

    class Error < Vagrant::Errors::VagrantError
      def to_s
        extra_data[:stdout]
      end
    end
  end
end
