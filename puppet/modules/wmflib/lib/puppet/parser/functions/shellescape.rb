# Escapes a string so it can be used as a shell argument
# (wraps it in quotes and deals with any quotes inside).
#
# shellescape("a'b")
# # => "'a\'b'"

require 'shellwords'

module Puppet::Parser::Functions
  newfunction(:shellescape, :type => :rvalue, :doc => <<-EOS
    Escapes a string so it can be used as a shell
    argument (wraps it in single quotes and deals
    with any single quotes inside).
    EOS
  ) do |args|
    raise(Puppet::ParseError, 'shellescape(): Wrong number of arguments') if args.length != 1
    shellescape(args[0])
  end
end

def shellescape(str)
  Shellwords.shellescape(str.to_s)
end
