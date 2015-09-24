require 'optparse'
require 'rubygems'

module MediaWikiVagrant
  # Assists with the setup of MediaWiki-Vagrant.
  #
  # Provides an interactive set of prompts for configuration of required
  # settings, installs plugin dependencies, and builds and installs the
  # mediawiki-vagrant plugin.
  #
  class Setup
    PLUGINS = ['vagrant-vbguest']

    class ExecutionError < RuntimeError
      attr_reader :command, :status

      def initialize(command, status)
        @command = command
        @status = status
      end

      def to_s
        "Failed to execute command `#{command}` (#{status})"
      end
    end

    attr_reader :directory, :options

    # Creates a new setup runner from the given command-line invocation.
    #
    def initialize(invocation)
      @silent = false
      @directory = File.expand_path('..', invocation)

      @options = OptionParser.new do |parser|
        parser.banner = "Usage: #{invocation}"

        parser.on('-s', '--silent', 'Run silently with no prompts or output') do
          @silent = true
        end

        parser.on_tail('-h', '--help', 'Show this help message.') do
          puts parser
          exit
        end
      end
    end

    # Executes the setup runner. Installs plugin dependencies, builds and
    # installs the mediawiki-vagrant plugin, and prompts the user to
    # configure any required settings.
    #
    def run
      @options.parse!

      # Install/update plugins
      (PLUGINS & installed_plugins).each { |plugin| update_plugin(plugin) }
      (PLUGINS - installed_plugins).each { |plugin| install_plugin(plugin) }

      # Install/update mediawiki-vagrant plugin
      gem_path = build_gem

      begin
        install_plugin(gem_path)
      ensure
        Dir['mediawiki-vagrant-*.gem'].each { |gem| File.unlink(gem) }
      end

      # Configure required settings
      configure_settings unless @silent

      notify "\nYou're all set! Simply run `vagrant up` to boot your new environment."
      notify "\n(Or try `vagrant config --list` to see what else you can tweak.)"
    end

    private

    # Builds mediawiki-vagrant from the bundled gemspec.
    #
    def build_gem
      spec = Gem::Specification.load(File.join(@directory, 'mediawiki-vagrant.gemspec'))

      # Support older versions of RubyGems as best we can
      if defined?(Gem::Builder)
        build_gem_using_builder(spec)
      else
        build_gem_using_package(spec)
      end
    end

    # Builds mediawiki-vagrant on systems with an older version of
    # RubyGems (< 2.0).
    #
    def build_gem_using_builder(spec)
      pwd = Dir.pwd
      verbose = Gem.configuration.verbose

      Dir.chdir(File.expand_path('..', spec.loaded_from))
      Gem.configuration.verbose = false

      Gem::Builder.new(spec).build
    ensure
      Dir.chdir(pwd)
      Gem.configuration.verbose = verbose
    end

    # Builds mediawiki-vagrant on systems with a newer version of RubyGems
    # (>= 2.0).
    #
    def build_gem_using_package(spec)
      require 'rubygems/package'

      package = Gem::Package.new(spec.file_name)
      package.spec = spec
      package.use_ui(Gem::SilentUI.new) { package.build }

      spec.file_name
    end

    # Prompts the user to configure required settings.
    #
    def configure_settings
      vagrant('config', '--required') { |pipe| pipe.each_char { |c| print c } }
    end

    # Installs the given Vagrant plugin.
    #
    def install_plugin(name)
      notify "Installing plugin #{name}"
      vagrant('plugin', 'install', name)
    end

    # Currently installed Vagrant plugins.
    #
    def installed_plugins
      @installed_plugins ||= vagrant('plugin', 'list') do |pipe|
        pipe.each_line.with_object([]) do |line, plugins|
          line.match(/^([\w\-]+) \([\w\.]+\)/) { |m| plugins << m[1] }
        end
      end
    end

    # Outputs the given message at the given indentation level unless we're
    # operating in silent mode.
    #
    def notify(message_or_io, level = 0)
      unless @silent
        prefix = ('-' * level) + (level > 0 ? ' ' : '')
        message_or_io.each_line { |line| puts "#{prefix}#{line}" }
      end
    end

    # Skips updates for already installed plugins.
    #
    def update_plugin(name)
      notify "Plugin #{name} is already installed"
    end

    # Executes the vagrant commands with the given arguments.
    #
    def vagrant(*args, &blk)
      command = ['vagrant'] + args
      blk ||= proc { |pipe| notify pipe, 1 }

      result = IO.popen(command, err: [:child, :out], &blk)
      raise ExecutionError.new(command.join(' '), $?) unless $?.success?

      result
    end
  end
end
