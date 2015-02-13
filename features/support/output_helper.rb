module MediaWikiVagrant
  module OutputHelper
    def output_column(column)
      column = [:first, :second, :third, :forth].index(column.to_sym) if column.is_a?(String)
      all_output.lines.map { |line| line.split[column] }
    end

    def output_table(width)
      all_output.lines.map { |line| line.split(/[ \t]+/, width).map(&:strip) }
    end
  end
end
