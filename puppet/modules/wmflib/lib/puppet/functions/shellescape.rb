# Escapes a string so it can be used as a shell argument
# (wraps it in quotes and deals with any quotes inside).
#
# shellescape("a'b")
# # => "'a\'b'"

require 'shellwords'

Puppet::Functions.create_function(:shellescape) do
  dispatch :shellescape do
    param 'Any', :input
  end

  def shellescape(input)
    Shellwords.shellescape(input.to_s)
  end
end
