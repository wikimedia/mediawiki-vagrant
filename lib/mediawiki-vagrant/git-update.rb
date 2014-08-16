class GitUpdates < Vagrant.plugin(2, :command)
    def self.synopsis
        "fetches new code from Gerrit"
    end

    def execute
        if %w(-h --help).include? @argv.first
            @env.ui.info 'Usage: vagrant git-update [-h]'
            return 0
        end

        with_target_vms(nil, :single_target => true) do |vm|
            opts = { :extra_args => @argv.unshift('run-git-update') }
            vm.action :ssh, :ssh_opts => opts
        end
    end
end
