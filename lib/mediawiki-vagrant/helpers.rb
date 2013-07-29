#!/usr/bin/env ruby
# Helper methods for MediaWiki-Vagrant
#
require 'rbconfig'

def windows?
    RbConfig::CONFIG['host_os'] =~ /mswin|msys|mingw32|windows/i
end

def commit
    File.read("#{$DIR}/.git/refs/heads/master")[0..7] rescue nil
end

def virtualbox_version
    cmd = windows? ?
        '"%ProgramFiles%\\Oracle\\VirtualBox\\VBoxManage" -v 2>NUL' :
        'VBoxManage -v 2>/dev/null'
    `#{cmd}`[/[\d\.]+/] rescue nil
end

# If it has been a week or more since remote commits have been fetched,
# run 'git fetch origin', unless the user disabled automatic fetching.
def update
    unless ENV.has_key? 'MWV_NO_UPDATE' or File.exist? "#{$DIR}/no-update"
        system('git fetch origin') if Time.now - File.mtime("#{$DIR}/.git/FETCH_HEAD") > 604800 rescue nil
    end
end


$manifest_path = File.join $DIR, 'puppet/manifests'

def roles_available
    IO.readlines(File.join $manifest_path, 'roles.pp').map { |line|
        /^[^#]*role::(\S+)/.match(line) and $1.tr(':', '#')
    }.compact.sort.uniq - ['generic', 'mediawiki']
end

def roles_enabled
    IO.readlines(File.join $manifest_path, 'manifests.d/vagrant-managed.pp').map { |line|
        /^[^#]*include role::(\S+)/.match(line) and $1.tr(':', '#')
    }.compact.sort.uniq rescue []
end

def update_roles(roles)
    File.open(File.join($manifest_path, 'manifests.d/vagrant-managed.pp'), 'w') { |f|
        f.puts '# This file is managed by Vagrant. Do not edit.'
        f.puts '# Use "vagrant list-roles / enable-role / disable-role" instead.'
        f.puts roles.sort.uniq.map { |r|
            "include role::#{r.gsub(/^role::/, '')}"
        }.join("\n")
    }
end
