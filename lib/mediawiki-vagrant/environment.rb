require 'fileutils'
require 'pathname'
require 'yaml'

require 'mediawiki-vagrant/settings'

module MediaWikiVagrant
  # Represents the current environment from which MediaWiki-Vagrant commands
  # are executed.
  #
  class Environment
    STALENESS = 604800

    class << self
      # Host operating system.
      #
      # @return [:osx, :linux, :windows, :unknown]
      #
      def operating_system
        case RbConfig::CONFIG['host_os']
        when /mac|darwin/i
          :osx
        when /linux/i
          :linux
        when /mswin|mingw|cygwin/i
          :windows
        else
          :unknown
        end
      end

      # Total host OS CPU cores.
      #
      # @return [Fixnum]
      #
      def total_cpus
        case operating_system
        when :osx
          `sysctl -n hw.ncpu`.to_i
        when :linux
          `nproc`.to_i
        when :windows
          `wmic CPU get NumberOfLogicalProcessors | more +1`.to_i
        else
          1
        end
      end

      # Total host OS memory in MB.
      #
      # @return [Fixnum]
      #
      def total_memory
        case operating_system
        when :osx
          `sysctl -n hw.memsize`.to_i / 1024 / 1024
        when :linux
          `awk '$1 == "MemTotal:" { print $2 }' /proc/meminfo`.to_i / 1024
        when :windows
          `wmic OS get TotalVisibleMemorySize | more +1`.to_i / 1024
        else
          0
        end
      end
    end

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

    # Configures settings for this environment using the given block.
    #
    # @yield [settings]
    # @yieldparam settings [Settings]
    #
    # @see Settings.configure
    #
    def configure_settings(&blk)
      Settings.configure(settings_path, &blk)
    end

    # Loads and returns settings for this environment. Additional files and
    # directories of settings can be loaded first by providing
    # `additional_paths`.
    #
    # @param *additional_paths [Array<String>]
    #
    # @return [Settings]
    #
    def load_settings(*additional_paths)
      settings = Settings.new

      (additional_paths.map { |p| path(p) } << settings_path).each do |path|
        settings.load(path) if path.exist?
      end

      settings
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

    # Get comment header for a role
    #
    def role_docstring(role)
      role_file = module_path("role/manifests/#{role}.pp")
      return nil unless role_file.exist?

      role_file.each_line.take_while { |line| line =~ /^#( |$)/ }.inject("") do |doc, line|
        doc << line.sub(/^# ?/, "")
      end
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
      FileUtils.rm_f Dir[path('settings.d/puppet-managed/*.php')]
      FileUtils.rm_rf path('settings.d/multiwiki')
      FileUtils.rm_rf path('settings.d/wikis')
      FileUtils.rm_rf path('vagrant.d')
      FileUtils.rm_f path('mediawiki/LocalSettings.php')
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

    def settings_path
      path('.settings.yaml')
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
