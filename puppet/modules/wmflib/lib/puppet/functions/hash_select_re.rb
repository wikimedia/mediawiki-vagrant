# hash_select_re.rb
#
# This function creates a new hash from the input hash, filtering out keys which
# do not match the provided regex.
#
# *Examples:*
#
#     $in = { 'abc' => 1, 'def' => 2, 'asdf' => 3 }
#     $out = hash_select_re('^a', $in);
#     # $out == { 'abc' => 1, 'asdf' => 3 }
#     $out2 = hash_select_re('^(?!a)', $in);
#     # $out2 == { 'def' => 2 }
#
Puppet::Functions.create_function(:hash_select_re) do
  dispatch :hash_select_re do
    param 'String', :pattern
    param 'Hash', :in_hash
  end

  def hash_select_re(pattern, in_hash)
    pattern = Regexp.new(pattern)
    in_hash.select { |k, _v| pattern.match(k) }
  end
end
