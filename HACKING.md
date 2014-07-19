# Puppet Code Conventions
We mostly follow https://wikitech.wikimedia.org/wiki/Puppet_coding

## Exec resources
* lowercase_with_underscore
* Omit path, unless it's useful for some reason (for example, /bin/true
  to avoid confusion with boolean true).
* No spaces in name (unless the name is the command).
* Prefer a short, human-readable name to a command.
