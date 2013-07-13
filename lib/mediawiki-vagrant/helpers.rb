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
