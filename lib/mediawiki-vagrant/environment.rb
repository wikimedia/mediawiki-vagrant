require 'fileutils'
require 'pathname'
require 'yaml'

module MediaWikiVagrant
    # Represents the current environment from which MediaWiki-Vagrant commands
    # are executed.
    #
    class Environment
        STALENESS = 604800

        # Initialize a new environment for the given directory.
        #
        def initialize(directory)
            @directory = directory
            @path = Pathname.new(@directory)
        end

        # The HEAD commit of local master branch, if we're executing from
        # within a cloned Git repo.
        #
        def commit
            master = path('.git/refs/heads/master')
            master.read[0..8] if master.exist?
        end

        # Returns an absolute path from the given relative path.
        #
        # @return [Pathname]
        #
        def path(*subpaths)
            @path.join(*subpaths)
        end

        # Removes all enabled roles that are no longer available.
        #
        def prune_roles
            migrate_roles
            update_roles(roles_enabled & roles_available)
        end

        # Returns all available Puppet roles.
        #
        # @return [Array]
        #
        def roles_available
            manifests = Dir[module_path('role/manifests/*.pp')]
            manifests.map! { |file| File.read(file).match(/^class\s*role::(\w+)/) { |m| m[1] } }
            manifests.compact.sort.uniq - ['generic', 'mediawiki', 'labs_initial_content']
        end

        # Returns enabled Puppet roles.
        #
        # @return [Array]
        #
        def roles_enabled
            migrate_roles

            hiera = hiera_load
            return [] unless hiera.key?('classes')

            roles = hiera['classes'].map do |r|
                r.match(/^role::(\S+)/) { |m| m[1] }
            end
            roles.compact.sort.uniq
        end

        # Updates the enabled Puppet roles to the given set.
        #
        def update_roles(roles)
            classes = roles.sort.uniq.map do |r|
                "role::#{r.sub(/^role::/, '')}"
            end
            hiera_set('classes', classes)
        end

        # If it has been a week or more since remote commits have been fetched,
        # run 'git fetch origin', unless the user disabled automatic fetching.
        # You can disable automatic fetching by creating an empty 'no-updates'
        # file in the root directory of your repository.
        #
        def update
            if stale_head? && !(ENV.include?('MWV_NO_UPDATE') || path('no-update').exist?)
                system('git fetch origin', chdir: @directory)
            end
        end

        # Whether this is a valid MediaWiki-Vagrant environment. This should
        # be used as a guard in middleware.
        #
        def valid?
            path('lib/mediawiki-vagrant.rb').exist?
        end

        # Removes files created by the puppet provisioner.
        #
        def purge_puppet_created_files
            FileUtils.rm Dir[path('settings.d/puppet-managed/*.php')]
            FileUtils.rm_r Dir[path('settings.d/multiwiki')]
            FileUtils.rm_r Dir[path('settings.d/wikis')]
        end

        # Deletes the given entry from the vagrant-managed hiera file.
        #
        # @param key [String]
        #
        def hiera_delete(key)
            if hiera_data.exist?
                hiera = hiera_load
                if hiera.key?(key)
                    hiera.delete(key)
                    hiera_save(hiera)
                end
            end
        end

        # Returns the value of the given entry in the vagrant-managed hiera
        # file, or nil if none exists.
        #
        # @param key [String]
        #
        # @return [Object]
        #
        def hiera_get(key)
          hiera_load[key]
        end

        # Saves the given key/value pair to the vagrant-managed hiera file.
        #
        # @param key [String]
        # @param value [Object]
        #
        # @return [Hash] New hiera settings.
        #
        def hiera_set(key, value)
            hiera_load.tap do |hiera|
                hiera[key] = value
                hiera_save(hiera)
            end
        end

        private

        def module_path(*subpaths)
            path('puppet/modules', *subpaths)
        end

        def hiera_data
            path('puppet/hieradata/vagrant-managed.yaml')
        end

        def hiera_load
            return {} unless hiera_data.exist?
            hiera_data.open('r') { |io| YAML.load(io) }
        end

        def hiera_save(data)
            hiera_data.open('w') { |f| f.write(YAML.dump(data)) }
        end

        def stale_head?
            head = path('.git/FETCH_HEAD')
            head.exist? && (Time.now - head.mtime) > STALENESS
        end

        # Migrate legacy roles to new format
        #
        def migrate_roles
            legacy_file = path('puppet/manifests/manifests.d/vagrant-managed.pp')
            if legacy_file.exist?
                legacy_roles = legacy_file.each_line.map do |l|
                    l.match(/^[^#]*include role::(\S+)/) { |m| m[1] }
                end
                update_roles(legacy_roles.compact.sort.uniq)
                FileUtils.rm legacy_file
            end
        end

    end
end
