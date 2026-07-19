# == Function: array_concat( $args... )
#
# Concatenates things into an array.
# Array arguments are concatenated together
# Other types (e.g. Hashes, Strings) are included as whole single elements
#
# === Examples
#
# $a1 = [ 'a', 'b', 'c' ]
# $a2 = [ 'd', 'e' ]
# $a3 = 'f'
# $a4 = { 'g' => 'h' }
# $all = array_concat($a1, $a2, $a3, $a4)
# ### $all == [ 'a', 'b', 'c', 'd', 'e', 'f', { 'g' => 'h' } ]
#
Puppet::Functions.create_function(:array_concat) do
  dispatch :array_concat do
    repeated_param 'Any', :items
  end

  def array_concat(*items)
    items.each_with_object([]) do |item, retval|
      if item.is_a?(Array)
        retval.concat(item)
      else
        retval << item
      end
    end
  end
end
