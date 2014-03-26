# coding: UTF-8
# puppet-shout - Shout at the user
#
require 'puppet/type'

Puppet::Type.newtype(:shout) do
    @doc = "Tell the user about something important.

        Example:

            shout {'at the devil':
                message => 'Mötley Crüe rulz! \m/',
            }
    "

    newproperty(:message) do
        desc "The message to shout."

        def sync
            banner = '!' * 78
            pad = ' ' * 4
            msg = self.should.split("\n").map! {|m| m.strip}
            msg = msg.join("\n#{pad}")
            Puppet.send('alert',
                "\n#{banner}\n#{pad}#{msg}\n#{banner}")
            return
        end

        def retrieve
            :absent
        end

        def insync?(is)
            # Shout unless we are only fired on refresh
            sync unless @resource[:refreshonly] == :true

            # Horrible hack! We always return true from insync? so that puppet
            # doesn't log a notice of the value change in addition to the
            # announcement we may make.
            true
        end

        defaultto { @resource[:name] }
    end

    newparam(:refreshonly) do
        desc "Whether or not to repeatedly call this resource. If true, this
            resource will only be executed when another resource tells it to
            do so. If set to false, it will execute at each run."
        defaultto :true
        newvalues(:true, :false)
    end

    newparam(:name) do
        desc "The name of the shout resource"
        isnamevar
    end

    def refresh
        self.property(:message).sync
    end
end
