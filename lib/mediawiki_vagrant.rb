#!/usr/bin/env ruby
# Helper methods for MediaWiki-Vagrant
#
require 'rbconfig'

PATH = File.expand_path('../..', __FILE__)


def windows?
    RbConfig::CONFIG['host_os'] =~ /mswin|msys|mingw32|windows/i
end

def commit
    File.read("#{PATH}/.git/refs/heads/master")[0..7] rescue nil
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
    unless ENV.has_key? 'MWV_NO_UPDATE' or File.exist? "#{PATH}/no-update"
        system('git fetch origin') if Time.now - File.mtime("#{PATH}/.git/FETCH_HEAD") > 604800 rescue nil
    end
end
