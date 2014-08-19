# == Class role::hue
# Installs Hue server.
#
class role::hue {
    require ::role::hadoop
    require ::role::hive
    require ::role::oozie
    require ::cdh::pig
    require ::cdh::sqoop
    require ::cdh::hue
}
