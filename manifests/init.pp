# @summary Class to manage installation and configuration of Tomcat.  
#
# @param catalina_home
#   Specifies the default root directory of the Tomcat installation. Valid options: a string containing an absolute path.
# @param user
#   Specifies a default user to run Tomcat as. Valid options: a string containing a valid username.
# @param group
#   Specifies a default group to run Tomcat as. Valid options: a string containing a valid group name.
# @param install_from_source
#   No longer available in the base class. Please use install_from_source on a specific tomcat::install declaration instead.
# @param purge_connectors
#   Specifies whether to purge any unmanaged Connector elements that match defined protocol but have a different port from the configuration file by default.
# @param purge_realms
#   Specifies whether to purge any unmanaged realm elements from the configuration file by default. If two realms are defined for a specific server config only use `purge_realms` for the first realm and ensure the realms enforce a strict order between each other.
# @param manage_user
#   Determines whether defined types should default to creating the specified user, if it doesn't exist. Uses Puppet's native [user](https://docs.puppetlabs.com/references/latest/type.html#user) with default parameters.
# @param manage_group
#   Determines whether defined types should default to creating the specified group, if it doesn't exist. Uses Puppet's native [group](https://docs.puppetlabs.com/references/latest/type.html#group) with default parameters.
# @param manage_home
#   Specifies the default value of `manage_home` for all `tomcat::instance` instances.
# @param manage_base
#   Specifies the default value of `manage_base` for all `tomcat::install` instances.
# @param manage_properties
#   Specifies the default value of `manage_properties` for all `tomcat::instance` instances.
#
class tomcat (
  $catalina_home             = '/opt/apache-tomcat',
  $user                      = 'tomcat',
  $group                     = 'tomcat',
  $install_from_source       = undef,
  Boolean $purge_connectors  = false,
  Boolean $purge_realms      = false,
  Boolean $manage_user       = true,
  Boolean $manage_group      = true,
  Boolean $manage_home       = true,
  Boolean $manage_base       = true,
  Boolean $manage_properties = true,
) {

  if $install_from_source {
    fail('install_from_source is no longer available in the base class. Please use install_from_source on a specific tomcat::install declaration instead.') # lint:ignore:140chars
  }
  case $::osfamily {
    'windows': {
      warning("Experimenal osfamily: ${::osfamily}")
    }
    'Solaris','Darwin': {
      fail("Unsupported osfamily: ${::osfamily}")
    }
    default: { }
  }
}
