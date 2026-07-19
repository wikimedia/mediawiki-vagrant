# == Function: ordered_json( hash $data [, hash $... ] )
#
# Serialize a hash into JSON with lexicographically sorted keys.
#
# Because the order of keys in Ruby 1.8 hashes is undefined, 'to_pson'
# is not idempotent: i.e., the serialized form of the same hash object
# can vary from one invocation to the next. This causes problems
# whenever a JSON-serialized hash is included in a file template,
# because the variations in key order are picked up as file updates by
# Puppet, causing Puppet to replace the file and refresh dependent
# resources on every run.
#
# === Examples
#
#   # Render a Puppet hash as a configuration file:
#   $options = { 'useGraphite' => true, 'minVal' => '0.1' }
#   file { '/etc/kibana/config.json':
#     content => ordered_json($options),
#   }
#
require 'json'

Puppet::Functions.create_function(:ordered_json) do
  dispatch :ordered_json do
    param 'Data', :first
    repeated_param 'Data', :rest
  end

  def ordered_json(first, *rest)
    render(([first] + rest).reduce(&:merge))
  end

  private

  def render(o)
    case o
    when Array
      '[' + o.map { |x| render(x) }.join(', ') + ']'
    when Hash
      '{' + o.sort.map { |k, v| k.to_json + ': ' + render(v) }.join(', ') + '}'
    else
      render_scalar(o)
    end
  end

  def render_scalar(o)
    o.include?('.') ? Float(o).to_s : Integer(o).to_s
  rescue StandardError, ArgumentError
    o.to_json
  end
end
