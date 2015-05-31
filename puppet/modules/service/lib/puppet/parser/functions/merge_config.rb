# == Function: merge_config(string|hash main_conf, string|hash service_conf)
#
# Merges the service-specific service_conf into main_conf. Both arguments
# can be either hashes or YAML-formatted strings. It returns the merged
# configuration hash.
#

module Puppet::Parser::Functions
  newfunction(:merge_config, :type => :rvalue, :arity => 2) do |args|
    main_conf, service_conf = *args.map do |conf|
      case conf
        when Hash
          conf.empty? ? '' : function_ordered_yaml([conf])
        when String
          conf
        else
          ''
      end
    end
    main_conf += service_conf.split("\n").map do |line|
      line.empty? ? '' : '      ' + line
    end.join("\n")
    main_conf
  end
end
