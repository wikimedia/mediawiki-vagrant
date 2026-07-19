# Takes a hash of parameters and turns them into a properly encoded URL query string.
# Keys with a nil value are dropped.
#
# make_url('http://example.com/', {})
# # => 'http:://example.com/'
#
# make_url('http://example.com/', { foo => 'bar', at => '&' })
# # => 'http:://example.com/?foo=bar&at=%26'

Puppet::Functions.create_function(:make_url) do
  dispatch :make_url do
    param 'Hash', :query_params
  end

  def make_url(query_params)
    query_params
      .reject { |_k, v| v.nil? }
      .map { |k, v| "#{escape(k)}=#{escape(v)}" }
      .join('&')
  end

  private

  # Percent-encode the reserved/gen-delim/sub-delim characters and space,
  # equivalent to the old (now-removed) URI.escape(str, ":/?#[]@!$&'()*+,;= ").
  def escape(str)
    str.to_s.gsub(/[:\/?#\[\]@!$&'()*+,;= ]/) { |c| format('%%%02X', c.ord) }
  end
end
