# Set RubyGems's GEM_HOME to $HOME/.gem
# This file is managed by Puppet.
#
mkdir -p /home/vagrant/.gem
export GEM_HOME=/home/vagrant/.gem
export PATH=$PATH:$GEM_HOME/bin