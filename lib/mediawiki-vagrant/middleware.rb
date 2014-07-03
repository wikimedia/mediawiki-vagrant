require 'mediawiki-vagrant/environment'

module MediaWikiVagrant
    class Middleware
        def initialize(app, env)
            @app = app
            @mwv = Environment.new(env[:root_path])
        end

        def call(env)
            @mwv.prune_roles
            $FACTER['provider_name'] = env[:machine].provider_name
            @app.call(env)
        end
    end
end
