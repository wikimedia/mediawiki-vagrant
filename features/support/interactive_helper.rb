require 'expect'
require 'io/console'
require 'pty'
require 'timeout'

require 'pry-byebug'

module MediaWikiVagrant
  module InteractiveHelper
    def run_with_pty(cmd)
      in_current_dir do
        @pty_out, @pty_in, @pty_pid = PTY.spawn(cmd)
        @pty_output = ''
      end
    end

    def expect_pty_output(pattern, timeout: 5)
      result = pty_operation { @pty_out.expect(pattern, timeout) }
      raise "command didn't output `#{pattern}` within #{timeout} seconds" if result.nil?
      @pty_output.concat(result.first)
      result
    end

    def pty_output
      output = pty_operation { @pty_out.read }
      @pty_output.concat(output) unless output.nil?
      @pty_output
    end

    def pty_process?
      !@pty_pid.nil?
    end

    def type_on_pty(input)
      @pty_in.puts(input)
    end

    def status_of_pty_process
      @pty_pid, @pty_status = Timeout.timeout(5) do
        pty_output
        Process.wait2(@pty_pid)
      end

      @pty_status
    end

    private

    def pty_operation
      yield
    rescue Errno::EIO
      nil
    end
  end
end
