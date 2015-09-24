require 'net/http'
require 'pathname'

require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
  class PastePuppet < Vagrant.plugin(2, :command)
    include PluginEnvironment

    URL = URI.parse('https://dpaste.de/api/')

    def self.synopsis
      'uploads your puppet logs to dpaste.de pastebin'
    end

    def execute
      begin
        res = Net::HTTP.post_form URL, content: latest_logfile.read
        raise unless res.value.nil? && res.body =~ /^"[^"]+"$/
      rescue RuntimeError
        @env.ui.error "Unexpected response from #{URL}."
        1
      rescue TypeError
        @env.ui.error 'No Puppet log files found.'
        1
      rescue SocketError, Net::HTTPExceptions
        @env.ui.error "Unable to connect to #{URL}."
        1
      else
        @env.ui.success "HTTP #{res.code} #{res.msg}"
        @env.ui.info res.body[1...-1]
        0
      end
    end

    private

    def latest_logfile
      Pathname.glob(@mwv.path('logs', 'puppet', '*.log')).max_by(&:mtime)
    end
  end
end
