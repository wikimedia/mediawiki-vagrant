module MediaWikiVagrant
    class Reload < Vagrant.plugin('2', :provisioner)
        def provision
            vagrant_home = File.expand_path @machine.env.root_path
            settings_dir = File.join(vagrant_home, 'vagrant.d')
            reload_trigger = File.join(settings_dir, 'RELOAD')
            if File.exists?(reload_trigger)
                @machine.ui.warn 'Reloading vagrant...'
                File.delete(reload_trigger)
                @machine.action(:reload, {})
                until @machine.communicate.ready? do
                    sleep 0.5
                end
                @machine.ui.success 'Vagrant reloaded.'
            end
        end
    end
end
