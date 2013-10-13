module MediaWikiVagrant
    COMMIT_CHANGES = "Ok. Run 'vagrant provision' to commit your changes."

    class ListRoles < Vagrant.plugin(2, :command)
        def execute
            @env.ui.info "Available roles:\n\n"
            enabled = roles_enabled
            roles_available.each { |role|
                prefix = enabled.include?(role) ? '*' : ' '
                @env.ui.info "#{prefix} #{role}"
            }
            @env.ui.info "\nRoles marked with '*' are enabled."
            @env.ui.info 'Use "vagrant enable-role" & "vagrant disable-role" to customize.'
            return 0
        end
    end

    class EnableRole < Vagrant.plugin(2, :command)
        def execute
            if @argv.empty? or ['-h', '--help'].include? @argv.first
                @env.ui.info 'Enable an optional role (run "vagrant list-roles" for a list).'
                @env.ui.info 'USAGE: vagrant enable-role ROLE'
                return 0
            end
            avail = roles_available
            @argv.map!(&:downcase)
            @argv.each do |r|
                if not avail.include? r
                    @env.ui.error "'#{r}' is not a valid role."
                    return 1
                end
            end
            update_roles(roles_enabled + @argv)
            @env.ui.info COMMIT_CHANGES
            return 0
        end
    end

    class DisableRole < Vagrant.plugin(2, :command)
        def execute
            if @argv.empty? or ['-h', '--help'].include? @argv.first
                @env.ui.info 'Disable one or more optional roles.'
                @env.ui.info 'USAGE: vagrant disable-role ROLE'
                return 0
            end
            enabled = roles_enabled
            @argv.map!(&:downcase)
            @argv.each do |r|
                if not enabled.include? r
                    @env.ui.error "'#{r}' is not enabled."
                    return 1
                end
            end
            update_roles(enabled - @argv)
            @env.ui.info COMMIT_CHANGES
            return 0
        end
    end

    class ResetRoles < Vagrant.plugin(2, :command)
        def execute
            if not @argv.empty? or ['-h', '--help'].include? @argv.first
                @env.ui.info 'Disable all optional roles.'
                @env.ui.info 'USAGE: vagrant reset-roles'
                return 0
            end
            update_roles []
            @env.ui.warn "All roles were disabled."
            @env.ui.info COMMIT_CHANGES
            return 0
        end
    end

end
