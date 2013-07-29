class RunTests < Vagrant.plugin(2, :command)
    def execute
        if ['-h', '--help'].include? @argv.first
            @env.ui.info "Usage: vagrant run-tests [tests] [-h]"
            return 0
        end
        opts = { extra_args: @argv.unshift('run-mediawiki-tests') }
        with_target_vms(nil, :single_target => true) do |vm|
            vm.action :ssh, ssh_opts: opts
        end
    end
end
