require 'mediawiki-vagrant/environment'

module MediaWikiVagrant
  module PluginEnvironment
    def initialize(*args)
      super
      env = @env || @machine.env
      @mwv = Environment.new(env.root_path || env.cwd)
    end

    # Whether we're sending output to an interactive terminal.
    #
    # @return [true, false]
    #
    def interactive_out?
      $stdout.tty?
    end
  end
end
