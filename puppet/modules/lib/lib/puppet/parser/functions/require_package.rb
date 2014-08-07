module Puppet::Parser::Functions
    newfunction(:require_package) do |args|
        unless args.length == 1 && args.first.is_a?(String)
            raise ArgumentError, 'require_package() takes a single string argument'
        end

        Puppet::Parser::Functions.function :create_resources
        Puppet::Parser::Functions.function :require

        def self.create_closure(name, scope)
            type = Puppet::Resource::Type.new :hostclass, name
            known_resource_types.add(type)
            cls = Puppet::Parser::Resource.new 'class', name, :scope => scope
            begin
                catalog.add_resource(cls)
                type.evaluate_code(cls)
            rescue Puppet::Resource::Catalog::DuplicateResourceError
            end
            scope.class_scope(type)
        end

        package_name = args.first
        class_name = 'packages::' + package_name.tr('-', '_')
        class_scope = create_closure(class_name, compiler.topscope)
        begin
            class_scope.function_create_resources [
                'package', {package_name => {:ensure => :present}}]
        rescue Puppet::Resource::Catalog::DuplicateResourceError
        end
        function_require [class_name]
    end
end
