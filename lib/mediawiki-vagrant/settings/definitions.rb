require 'mediawiki-vagrant/settings'

module MediaWikiVagrant
  Settings.define do
    setting :git_user,
      description: "Your git/Gerrit username",
      help: "Enter 'anonymous' for anonymous access, leave blank to manage it yourself",
      allows_empty: true

    setting :vagrant_ram,
      description: "Amount of RAM (in MB) allocated to the guest VM",
      help: "Specify 'auto' to automatically allocate 1/4 of your system's memory",
      default: 1536,
      auto: -> { Environment.total_memory / 4 },
      coercion: ->(setting, new) { [setting.default, new.to_i].max },
      combiner: ->(setting, new) { setting.value + new.to_i }

    setting :vagrant_cores,
      description: "CPU cores allocated to the guest VM",
      help: "All of your host system's cores are allocated by default.",
      default: :auto,
      auto: -> { Environment.total_cpus },
      coercion: ->(setting, new) { new && new.to_i }

    setting :static_ip,
      description: "IP address assigned to the guest VM",
      default: "10.11.12.13"

    setting :http_port,
      description: "Host port forwarded to the guest VM's HTTP server (port 80)",
      default: 8080,
      coercion: ->(setting, new) { new && new.to_i }

    setting :nfs_shares,
      description: "Use synced folders backed by NFS",
      help: "Enter 'yes' or 'no'. NFS is faster, but unsupported on Windows and with some encrypted filesystems on Linux",
      default: defined?(Vagrant::Util::Platform) ? !Vagrant::Util::Platform.windows? : true,
      coercion: ->(setting, new) { !!(new.to_s =~ /^(true|t|yes|y|1)$/i) }

    setting :nfs_cache,
      description: "Use cachefilesd to speed up NFS file access (EXPERIMENTAL)",
      help: "Enter 'yes' or 'no'. If your VM is currently running, reload it after changing this setting.",
      default: false,
      coercion: ->(setting, new) { !!(new.to_s =~ /^(true|t|yes|y|1)$/i) }

    setting :forward_agent,
      description: "Enable agent forwarding over SSH connections by default",
      help: "Enter 'yes' or 'no'. Agent forwarding requires an SSH agent running on the host computer.",
      default: false,
      coercion: ->(setting, new) { !!(new.to_s =~ /^(true|t|yes|y|1)$/i) }

    setting :forward_ports,
      internal: true,
      default: {},
      coercion: ->(setting, new) { setting.value.merge(Hash[new.map { |kv| kv.map(&:to_i) }]) }

    setting :forward_x11,
      description: "Enable X11 forwarding over SSH connections by default",
      help: "Enter 'yes' or 'no'. X11 forwarding enables GUI applications to be run on the guest.",
      default: true,
      coercion: ->(setting, new) { !!(new.to_s =~ /^(true|t|yes|y|1)$/i) }
  end
end
