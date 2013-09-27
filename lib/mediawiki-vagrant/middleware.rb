module MediaWikiVagrant
    class Middleware
        def initialize(app, env)
            @app = app
        end

        def call(env)
            $FACTER['provider_name'] = env[:machine].provider_name
            $FACTER['provider_version'] = env[:machine].provider.driver.version
            @app.call(env)
        end
    end
end
