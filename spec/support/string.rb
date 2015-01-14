module MediaWikiVagrant
  module SpecHelpers
    module String
      # Removes the least amount of leading spaces from the beginning of each
      # line in order to left align the given string. This method helps to
      # keep things tidy when using heredocs in examples.
      #
      # @example
      #   align(<<-end)
      #     foo
      #       bar
      #   end
      #   # => "foo\n  bar"
      #
      def align(str)
        padding = str.each_line.reduce(nil) do |min, line|
          line_padding = line.match(/^( +)[^ ]/) { |m| m[1].length }

          if min && line_padding
            [min, line_padding].min
          else
            min || line_padding
          end
        end

        padding.nil? ? str : str.gsub(/^ {#{padding}}/, '')
      end
    end
  end
end
