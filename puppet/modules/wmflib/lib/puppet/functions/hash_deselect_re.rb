# hash_deselect_re.rb
#
# This function creates a new hash from the input hash, filtering out keys which
# match the provided regex.
#
# *Examples:*
#
#     $in = { 'abc' => 1, 'def' => 2, 'asdf' => 3 }
#     $out = hash_deselect_re('^a', $in);
#     # $out == { 'def' => 2 }
#     $out2 = hash_deselect_re('^(?!a)', $in);
#     # $out2 == { 'abc' => 1, 'asdf' => 3 }
#
Puppet::Functions.create_function(:hash_deselect_re) do
  dispatch :hash_deselect_re do
    param 'String', :pattern
    param 'Hash', :in_hash
  end

  def hash_deselect_re(pattern, in_hash)
    pattern = Regexp.new(pattern)
    in_hash.reject { |k, _v| pattern.match(k) }
  end
end
