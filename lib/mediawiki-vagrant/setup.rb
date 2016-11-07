require 'English'
require 'optparse'
require 'rubygems'

module MediaWikiVagrant
  # Assists with the setup of MediaWiki-Vagrant.
  #
  # Provides an interactive set of prompts for configuration of required
  # settings.
  #
  class Setup
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

    # Prompt the user to configure any required settings.
    #
    def run
      @options.parse!

      # Configure required settings
      configure_settings unless @silent

      notify "\nYou're all set! Simply run `vagrant up` to boot your new environment."
      notify "\n(Or try `vagrant config --list` to see what else you can tweak.)"
    end

    private

    # Prompts the user to configure required settings.
    #
    def configure_settings
      vagrant('config', '--required') { |pipe| pipe.each_char { |c| print c } }
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

    # Executes the vagrant commands with the given arguments.
    #
    def vagrant(*args, &blk)
      command = ['vagrant'] + args
      blk ||= proc { |pipe| notify pipe, 1 }

      result = IO.popen(command, err: [:child, :out], &blk)
      raise ExecutionError.new(command.join(' '), $CHILD_STATUS) unless $CHILD_STATUS.success?

      result
    end
  end
end
