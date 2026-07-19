# == Function: validate_ensure( string $ensure )
#
# Throw an error if the $ensure argument is not 'present' or 'absent'.
#
# === Examples
#
#  # Abort compilation if $ensure is invalid
#  validate_ensure($ensure)
#
Puppet::Functions.create_function(:validate_ensure) do
  dispatch :validate_ensure do
    param 'Any', :ensure_value
  end

  def validate_ensure(ensure_value)
    unless %w(present absent).include?(ensure_value)
      fail(Puppet::ParseError, "$ensure must be \"present\" or \"absent\" (got: #{ensure_value.inspect}).")
    end
  end
end
