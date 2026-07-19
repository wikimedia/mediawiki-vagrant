# == Function: validate_array_re( array $items, string $re )
#
# Throw an error if any member of $items does not match the regular
# expression $re.
#
# === Examples
#
#  # OK -- each array item is a four-digit number.
#  validate_array_re([8123, 8124, 8125], '^\d{4}$')
#
#  # Fail -- last array item is not a four-digit number.
#  validate_array_re([8123, 8124, 812], '^\d{4}$')
#
Puppet::Functions.create_function(:validate_array_re) do
  dispatch :validate_array_re do
    param 'Array', :items
    param 'String', :re
  end

  def validate_array_re(items, re)
    pattern = Regexp.new(re)
    invalid = items.find { |item| item.to_s !~ pattern }
    unless invalid.nil?
      fail(Puppet::ParseError, "Array element \"#{invalid}\" does not match regular expression \"#{pattern.source}\".")
    end
  end
end
