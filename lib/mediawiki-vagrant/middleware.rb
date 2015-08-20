require 'mediawiki-vagrant/environment'

module MediaWikiVagrant
  class Middleware
    def initialize(app, env)
      @app = app
      @mwv = Environment.new(env[:root_path])
    end

    def call(env)
      if @mwv.valid?
        @mwv.prune_roles

        # Add the name of the current provider to our puppet facts
        env[:machine].config.vm.provisioners.each do |provisioner|
          # Note that `VagrantPlugins::Kernel_V2::VagrantConfigProvisioner`
          # `#name` in Vagrant <= 1.6 is `#type` in Vagrant > 1.6 :/
          if (provisioner.name || provisioner.type) == :puppet
            provisioner.config.facter['provider_name'] = env[:machine].provider_name
          end
        end
      end

      @app.call(env)
    end
  end
end
