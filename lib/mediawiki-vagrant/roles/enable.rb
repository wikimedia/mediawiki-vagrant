require 'mediawiki-vagrant/plugin_environment'
require 'mediawiki-vagrant/roles/change'
require 'mediawiki-vagrant/settings_plugin'

module MediaWikiVagrant
  module Roles
    class Enable < Change
      def self.synopsis
        "enables a mediawiki-vagrant role"
      end

      private

      def banner
        'Enable an optional role (run `vagrant roles list` for a list).'
      end

      def new_roles(given_roles)
        @mwv.roles_enabled + given_roles
      end

      def possible_roles
        @mwv.roles_available
      end

      def role_error(role)
        "'#{role}' is not a valid role."
      end
    end
  end
end
