# Takes a hash of parameters and turns them into a properly encoded URL query string.
# Keys with a nil value are dropped.
#
# make_url('http://example.com/', {})
# # => 'http:://example.com/'
#
# make_url('http://example.com/', { foo => 'bar', at => '&' })
# # => 'http:://example.com/?foo=bar&at=%26'

require 'uri'

module Puppet::Parser::Functions
  newfunction(:make_url, :type => :rvalue, :doc => <<-EOS
    Takes a base URL and a hash of parameters and turns
    them into a properly encoded URL.
    EOS
  ) do |args|
    raise(Puppet::ParseError, 'make_url(): Wrong number of arguments') if args.length != 1
    raise(Puppet::ParseError, 'make_url(): Argument must be a hash') unless args[0].class == Hash
    make_url(args[0])
  end
end

def make_url(query_params)
  query_params
    .delete_if { |k, v| v.nil? }
    .collect { |k, v| escape(k) + '=' + escape(v) }
    .join('&')
end

def escape(str)
  URI.escape(str.to_s, ":/?#[]@!$&'()*+,;= ")
end
