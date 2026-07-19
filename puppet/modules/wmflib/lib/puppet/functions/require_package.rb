# == Function: require_package( string $package_name [, string $... ] )
#
# Declare one or more packages a dependency for the current scope.
# This is equivalent to declaring and requiring the package resources.
# In other words, it ensures the package(s) are installed before
# evaluating any of the resources in the current scope.
#
# === Examples
#
#  # Single package
#  require_package('python-redis')
#
#  # Multiple packages as arguments
#  require_package('redis-server', 'python-redis')
#
#  # Multiple packages as array
#  $deps = [ 'redis-server', 'python-redis' ]
#  require_package($deps)
#
Puppet::Functions.create_function(:require_package) do
  dispatch :require_package do
    repeated_param 'Any', :packages
  end

  def require_package(*packages)
    scope = closure_scope
    compiler = scope.compiler

    packages.flatten.each do |package_name|
      # Puppet class names are alphanumeric + underscore
      # 'g++' package would yield: 'packages::g__'
      class_name = 'packages::' + package_name.tr('-+', '_')

      # Create host class

      host = compiler.topscope.find_hostclass(class_name)
      unless host
        host = Puppet::Resource::Type.new(:hostclass, class_name)
        compiler.environment.known_resource_types.add_hostclass(host)
      end

      # Create class scope

      cls = Puppet::Parser::Resource.new(
        'class', class_name, :scope => compiler.topscope)
      scope.catalog.add_resource(cls) rescue nil
      host.evaluate_code(cls) rescue nil

      # Create package resource

      begin
        host_scope = compiler.topscope.class_scope(host)
        host_scope.call_function(:create_resources,
                                  ['package', { package_name => { :ensure => :present } }])
      rescue Puppet::Resource::Catalog::DuplicateResourceError
      end

      # Declare dependency
      call_function('require', class_name)
    end
  end
end
