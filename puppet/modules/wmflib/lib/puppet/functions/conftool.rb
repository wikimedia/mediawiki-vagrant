# == Function: conftool( string $tags, string $selector, string $object_type='node')
#
# Fetch values from conftool. This should be used only for things that depend on the dynamic
# state from conftool but do not require the tight coordination.
#
# It will get (and json parse) values from conftool and return them, based on the specified
# selector.
#
# === Examples
#
# # get the current status of a node in confctl
# $status = conftool({ name => 'cp1052.eqiad.wmnet', service => 'varnish-fe'}) # returns a list of associated services
#
require 'json'

Puppet::Functions.create_function(:conftool) do
  dispatch :conftool do
    param 'Hash', :tags
    optional_param 'String', :object_type
  end

  def conftool(tags, object_type = 'node')
    # Raise an error if tags is empty
    if tags.empty?
      raise Puppet::ParseError, "tags should be in hash format"
    end

    # get the data and return them parsed as json
    begin
      selector = tags.map { |k, v| "#{k}=#{v}" }.join(",")
      result = []
      data = call_function(
        'generate',
        '/usr/bin/confctl',
        '--object-type', object_type,
        'select', selector,
        'get'
      ).chomp

      # No result returns the empty list
      return [] if data.empty?

      data.split("\n").each do |line|
        entry = JSON.load(line)
        entry_tags = entry.delete 'tags'
        obj_name = entry.keys.pop
        result.push({'name' => obj_name, 'tags' => entry_tags, 'value' => entry[obj_name]})
      end
      result
    rescue StandardError => e
      raise Puppet::ParseError, "Unable to read data from conftool. Wrapped error is #{e}: #{e.message}"
    end
  end
end
