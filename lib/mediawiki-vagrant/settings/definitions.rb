require 'mediawiki-vagrant/settings'

MediaWikiVagrant::Settings.define do
    setting :git_user,
        description: "Your git/Gerrit username",
        help: "Enter 'anonymous' for anonymous access, leave blank to manage it yourself",
        allows_empty: true

    setting :vagrant_ram,
        description: "Amount of RAM (in MB) allocated to the guest VM",
        help: "Tasks such as browser tests may require more memory (minimum of 1024)",
        default: 1024,
        coercion: ->(setting, new) { [setting.default, new.to_i].max }

    setting :vagrant_cores,
        description: "CPU cores allocated to the guest VM",
        help: "If you're on a single-core system, be sure to enter '1'",
        default: 2,
        coercion: ->(setting, new) { new && new.to_i }

    setting :static_ip,
        description: "IP address assigned to the guest VM",
        default: "10.11.12.13"

    setting :http_port,
        description: "Host port forwarded to the guest VM's HTTP server (port 80)",
        default: 8080,
        coercion: ->(setting, new) { new && new.to_i }

    setting :forward_ports,
        internal: true,
        default: {},
        coercion: ->(setting, new) { setting.value.merge(Hash[new.map { |kv| kv.map(&:to_i) }]) }
end
