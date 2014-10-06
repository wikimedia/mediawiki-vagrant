require 'mediawiki-vagrant/plugin_environment'

module MediaWikiVagrant
    COMMIT_CHANGES = 'Ok. Run `vagrant provision` to apply your changes.'

    # Provides a command-line interface for managing Puppet roles.
    #
    class Roles < Vagrant.plugin(2, :command)
        include PluginEnvironment

        def self.synopsis
            'manage mediawiki-vagrant roles: list, enable, disable, etc.'
        end

        def initialize(argv, env)
            super

            @args, @command, @sub_args = split_main_and_subcommand(argv)

            @subcommands = Vagrant::Registry.new
            @subcommands.register(:list) do
                ListRoles
            end
            @subcommands.register(:reset) do
                ResetRoles
            end
            @subcommands.register(:enable) do
                EnableRole
            end
            @subcommands.register(:disable) do
                DisableRole
            end
        end

        def execute
            if @args.include?('-h') || @args.include?('--help')
                return help
            end

            command_class = @subcommands.get(@command.to_sym) if @command
            return help if !command_class || !@command

            command_class.new(@sub_args, @env).execute
        end

        def help
            opts = OptionParser.new do |o|
                o.banner = 'Usage: vagrant roles <command> [<args>]'
                o.separator ''
                o.separator 'Available subcommands:'

                commands = {}
                longest = 0
                @subcommands.each do |key, klass|
                    key           = key.to_s
                    commands[key] = klass.synopsis
                    longest       = key.length if key.length > longest
                end

                commands.keys.sort.each do |key|
                    o.separator "    #{key.ljust(longest+1)} #{commands[key]}"
                end

                o.separator ''
                o.separator 'For help on any individual command run `vagrant roles COMMAND -h`'
            end
            @env.ui.info(opts.help, prefix: false)
        end
    end

    class ListRoles < Vagrant.plugin(2, :command)
        include PluginEnvironment

        def self.synopsis
            "lists available mediawiki-vagrant roles"
        end

        def execute
            opts = OptionParser.new do |o|
                o.banner = 'Usage: vagrant roles list [-h]'
                o.separator ''
                o.separator '  List available roles.'
                o.separator ''
            end
            argv = parse_options(opts)
            return if !argv

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
            @env.ui.info 'Use `vagrant roles enable` & `vagrant roles disable` to customize.'
            return 0
        end
    end

    class EnableRole < Vagrant.plugin(2, :command)
        include PluginEnvironment

        def self.synopsis
            "enables a mediawiki-vagrant role"
        end

        def execute
            opts = OptionParser.new do |o|
                o.banner = 'Usage: vagrant roles enable <name> [<name2> <name3> ...] [-h]'
                o.separator ''
                o.separator '  Enable an optional role (run `vagrant roles list` for a list).'
                o.separator ''
            end
            argv = parse_options(opts)
            return if !argv
            raise Vagrant::Errors::CLIInvalidUsage, help: opts.help.chomp if argv.length < 1

            avail = @mwv.roles_available
            argv.map(&:downcase).each do |r|
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

        def self.synopsis
            "disables a mediawiki-vagrant role"
        end

        def execute
            opts = OptionParser.new do |o|
                o.banner = 'Usage: vagrant roles disable <name> [<name2> <name3> ...] [-h]'
                o.separator ''
                o.separator '  Disable one or more optional roles.'
                o.separator ''
            end
            argv = parse_options(opts)
            return if !argv
            raise Vagrant::Errors::CLIInvalidUsage, help: opts.help.chomp if argv.length < 1

            enabled = @mwv.roles_enabled
            argv.map(&:downcase).each do |r|
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

        def self.synopsis
            "disables all optional mediawiki-vagrant roles"
        end

        def execute
            opts = OptionParser.new do |o|
                o.banner = 'Usage: vagrant roles reset [-h]'
                o.separator ''
                o.separator '  Disable all optional roles.'
                o.separator ''
            end
            argv = parse_options(opts)
            return if !argv

            @mwv.update_roles []
            @env.ui.warn "All roles were disabled."
            @env.ui.info COMMIT_CHANGES
            return 0
        end
    end

end
