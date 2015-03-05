module MediaWikiVagrant
  module OutputHelper
    def stdout(bytes = 4096)
      normalize_output(@output << @stdout_r.readpartial(bytes))
    end

    def enter(line)
      @stdin_w.puts line
    end

    def output_column(column)
      column = [:first, :second, :third, :forth].index(column.to_sym) if column.is_a?(String)
      stdout.lines.map { |line| line.split[column] }
    end

    def output_table(width)
      stdout.lines.map { |line| line.split(/[ \t]+/, width).map(&:strip) }
    end

    private

    def normalize_output(output)
      output.gsub(/\r?\n/, "\n").gsub(/\e\[(\d+;)?(\d*)m/, '')
    end
  end
end
