module MediaWikiVagrant
  module LsbCheck
    # Validates lsb_release vendor and version
    #
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def provision
        execute_inline <<-end_
          set -e
          REQUIRED_VENDOR=#{config.vendor}
          REQUIRED_VERSION=#{config.version}
          VENDOR=$(lsb_release -is)
          VERSION=$(lsb_release -rs)
          if ! [[ $VENDOR == $REQUIRED_VENDOR && $VERSION =~ $REQUIRED_VERSION ]]; then
            echo "MediaWiki-Vagrant requires a $REQUIRED_VENDOR $REQUIRED_VERSION guest OS"
            echo 'Your guest OS reports:'
            lsb_release -irc | sed 's/^/    /'
            echo 'Please rebuild using `vagrant destroy -f; vagrant up`'
            echo 'NOTE: this will cause you to lose any data saved in the VM.'
            exit 1
          fi
        end_
      end

      private

      def execute_inline(script)
        @machine.communicate.tap do |comm|
          comm.execute("cat <<'EOF' | /usr/bin/env bash\n#{script}\nEOF", error_class: Error)
        end
      end
    end

    # Custom error to avoid need for l10n keys
    #
    class Error < Vagrant::Errors::VagrantError
      def to_s
        extra_data[:stdout]
      end
    end
  end
end
