#!/usr/bin/env ruby

require_relative 'mediawiki-vagrant/environment'
@mwv = MediaWikiVagrant::Environment.new('/vagrant')

COMMIT_CHANGES = "Ok. Run 'labs-vagrant provision' to apply your changes."

case ARGV.shift
when 'list-roles'
    puts "Available roles:\n\n"
    enabled = @mwv.roles_enabled
    roles = @mwv.roles_available.sort.map { |role|
        prefix = enabled.include?(role) ? '*' : ' '
        "#{prefix} #{role}"
    }
    col, *cols = roles.each_slice((roles.size/3.0).ceil).to_a
    col.zip(*cols) { |a,b,c|
        puts sprintf("%-26s %-26s %-26s", a, b, c)
    }
    puts "\nRoles marked with '*' are enabled."
    puts "Note that roles enabled by dependency are not marked."
    puts 'Use "labs-vagrant enable-role" & "labs-vagrant disable-role" to customize.'

when 'reset-roles'
    if not ARGV.empty? or ['-h', '--help'].include? ARGV.first
        puts 'Disable all optional roles.'
        puts 'USAGE: labs-vagrant reset-roles'
    end
    @mwv.update_roles []

    puts 'All roles were disabled.'
    puts COMMIT_CHANGES

when 'enable-role'
    if ARGV.empty? or ['-h', '--help'].include? ARGV.first
        puts 'Enable an optional role (run "labs-vagrant list-roles" for a list).'
        puts 'USAGE: labs-vagrant enable-role ROLE'
        return 0
    end
    avail = @mwv.roles_available
    ARGV.each do |r|
        if not avail.include? r
            puts "'#{r}' is not a valid role."
            return 1
        end
    end
    @mwv.update_roles(@mwv.roles_enabled + ARGV)
    puts COMMIT_CHANGES

when 'disable-role'
    if ARGV.empty? or ['-h', '--help'].include? ARGV.first
        puts 'Disable one or more optional roles.'
        puts 'USAGE: labs-vagrant disable-role ROLE'
        return 0
    end
    enabled = @mwv.roles_enabled
    ARGV.each do |r|
        if not enabled.include? r
            puts "'#{r}' is not enabled."
        end
    end
    @mwv.update_roles(enabled - ARGV)
    puts COMMIT_CHANGES

when 'provision'
    puppet_path = '/vagrant/puppet'
    exec "sudo puppet apply \
        --modulepath #{puppet_path}/modules \
        --manifestdir #{puppet_path}/manifests \
        --templatedir #{puppet_path}/templates \
        --fileserverconfig #{puppet_path}/extra/fileserver.conf \
        --config_version #{puppet_path}/extra/config-version \
        --verbose \
        --logdest console \
        --detailed-exitcodes \
        #{puppet_path}/manifests/site.pp"

else
    puts 'USAGE: labs-vagrant COMMAND ...'
    puts '  list-roles            : list available roles'
    puts '  reset-roles           : disable all roles'
    puts '  enable-role ROLENAME  : enable a given role'
    puts '  disable-role ROLENAME : disable a given role'
    puts '  provision             : run puppet'
end
