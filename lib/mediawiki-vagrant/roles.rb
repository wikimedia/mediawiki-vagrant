require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
    COMMIT_CHANGES = "Ok. Run 'vagrant provision' to apply your changes."

    class ListRoles < Vagrant.plugin(2, :command)
        include PluginEnvironment

        def execute
            @env.ui.info "Available roles:\n"
            enabled = @mwv.roles_enabled

            roles = @mwv.roles_available.sort.map { |role|
                prefix = enabled.include?(role) ? '*' : ' '
                "#{prefix} #{role}"
            }
            col, *cols = roles.each_slice((roles.size/3.0).ceil).to_a
            col.zip(*cols) { |a,b,c|
                @env.ui.info sprintf("%-26s %-26s %-26s", a, b, c)
            }

            @env.ui.info "\nRoles marked with '*' are enabled."
            @env.ui.info "Note that roles enabled by dependency are not marked."
            @env.ui.info 'Use "vagrant enable-role" & "vagrant disable-role" to customize.'
            return 0
        end
    end

    class EnableRole < Vagrant.plugin(2, :command)
        include PluginEnvironment

        def execute
            if @argv.empty? or ['-h', '--help'].include? @argv.first
                @env.ui.info 'Enable an optional role (run "vagrant list-roles" for a list).'
                @env.ui.info 'USAGE: vagrant enable-role ROLE'
                return 0
            end
            avail = @mwv.roles_available
            @argv = @argv.take_while { |r| r != '--' }.map(&:downcase)
            @argv.each do |r|
                if not avail.include? r
                    @env.ui.error "'#{r}' is not a valid role."
                    return 1
                end
            end
            @mwv.update_roles(@mwv.roles_enabled + @argv)
            @env.ui.info COMMIT_CHANGES
            return 0
        end
    end

    class DisableRole < Vagrant.plugin(2, :command)
        include PluginEnvironment

        def execute
            if @argv.empty? or ['-h', '--help'].include? @argv.first
                @env.ui.info 'Disable one or more optional roles.'
                @env.ui.info 'USAGE: vagrant disable-role ROLE'
                return 0
            end
            enabled = @mwv.roles_enabled
            @argv = @argv.take_while { |r| r != '--' }.map(&:downcase)
            @argv.each do |r|
                if not enabled.include? r
                    @env.ui.error "'#{r}' is not enabled."
                    return 1
                end
            end
            @mwv.update_roles(enabled - @argv)
            @env.ui.info COMMIT_CHANGES
            return 0
        end
    end

    class ResetRoles < Vagrant.plugin(2, :command)
        include PluginEnvironment

        def execute
            if ['-h', '--help'].include? @argv.first
                @env.ui.info 'Disable all optional roles.'
                @env.ui.info 'USAGE: vagrant reset-roles'
                return 0
            end
            @mwv.update_roles []
            @env.ui.warn "All roles were disabled."
            @env.ui.info COMMIT_CHANGES
            return 0
        end
    end

end
