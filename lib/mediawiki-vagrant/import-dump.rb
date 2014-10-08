class ImportDump < Vagrant.plugin(2, :command)
  def self.synopsis
    "imports an XML file into MediaWiki"
  end

  def execute
    if ['-h', '--help'].include? @argv.first
      @env.ui.info "Usage: vagrant import-dump dumpfile.xml [-h]"
      return 0
    end
    opts = { extra_args: @argv.unshift('import-mediawiki-dump') }
    with_target_vms(nil, :single_target => true) do |vm|
      vm.action :ssh, ssh_opts: opts
    end
  end
end
