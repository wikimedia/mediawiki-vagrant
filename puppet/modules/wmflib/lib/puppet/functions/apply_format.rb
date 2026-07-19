# == Function: apply_format( string $format, array $items )
#
# Apply a format string to each element of an array.
#
# === Examples
#
#  $languages = [ 'finnish', 'french', 'greek', 'hebrew' ]
#  $packages = apply_format('texlive-lang-%s', $languages)
#
Puppet::Functions.create_function(:apply_format) do
  dispatch :apply_format do
    param 'String', :format
    param 'Any', :items
  end

  def apply_format(format, items)
    [items].flatten.map { |item| format % item }
  end
end
