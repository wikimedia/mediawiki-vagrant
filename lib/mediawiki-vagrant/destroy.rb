require 'mediawiki-vagrant/environment'

module MediaWikiVagrant
  class Destroy
    def initialize(app, env)
      @app = app
      @mwv = Environment.new(env[:root_path] || env[:cwd])
    end

    def call(env)
      if @mwv.valid?
        env[:ui].info 'Removing puppet created files...'
        @mwv.purge_puppet_created_files
      end
      @app.call(env)
    end
  end
end
