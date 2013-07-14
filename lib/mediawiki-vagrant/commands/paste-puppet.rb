require 'net/http'

class PastePuppet < Vagrant.plugin(2, :command)

    URL = URI('http://dpaste.de/api/')

    def latest_logfile
        Dir[File.join $DIR, '/logs/puppet/*.log'].max_by { |f| File.mtime f }
    end

    def execute
        begin
            res = Net::HTTP.post_form URL, content: File.read(latest_logfile)
            raise unless res.value.nil? and res.body =~ /^"[^"]+"$/
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
end
