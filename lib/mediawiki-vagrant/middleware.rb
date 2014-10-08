require 'mediawiki-vagrant/environment'

module MediaWikiVagrant
  class Middleware
    def initialize(app, env)
      @app = app
      @mwv = Environment.new(env[:root_path])
    end

    def call(env)
      if @mwv.valid?
        @mwv.prune_roles
        $FACTER['provider_name'] = env[:machine].provider_name
      end

      @app.call(env)
    end
  end
end
