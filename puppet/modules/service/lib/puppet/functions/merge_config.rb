# == Function: merge_config(string|hash main_conf, string|hash service_conf)
#
# Merges the service-specific service_conf into main_conf. Both arguments
# can be either hashes or YAML-formatted strings. It returns the merged
# configuration hash.
#

def config_to_hash(conf)
  return YAML.load(conf) unless conf.is_a?(Hash)
  conf
end

Puppet::Functions.create_function(:merge_config) do
  dispatch :merge_config do
    param 'Variant[String, Hash]', :main_conf
    param 'Variant[String, Hash]', :service_conf
  end

  def merge_config(main_conf, service_conf)
    main_conf    = config_to_hash(main_conf)
    service_conf = config_to_hash(service_conf)

    begin
      main_conf['services'][0]['conf'].update(service_conf)
    rescue
      fail('Badly formatted configuration.')
    end

    call_function('ordered_yaml', main_conf)
  end

  def config_to_hash(conf)
    conf.is_a?(Hash) ? conf : YAML.load(conf)
  end
end
