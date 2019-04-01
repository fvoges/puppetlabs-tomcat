# tomcat

#### Table of Contents

- [tomcat](#tomcat)
      - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Module Description](#module-description)
  - [Setup](#setup)
    - [Requirements](#requirements)
    - [Beginning with tomcat](#beginning-with-tomcat)
  - [Usage](#usage)
    - [I want to run multiple instances of multiple versions of Tomcat](#i-want-to-run-multiple-instances-of-multiple-versions-of-tomcat)
    - [I want to configure SSL and specify which protocols and ciphers to use](#i-want-to-configure-ssl-and-specify-which-protocols-and-ciphers-to-use)
    - [I want to deploy WAR files](#i-want-to-deploy-war-files)
    - [I want to remove some configuration](#i-want-to-remove-some-configuration)
    - [I want to manage a Connector or Realm that already exists](#i-want-to-manage-a-connector-or-realm-that-already-exists)
  - [Reference](#reference)
  - [Limitations](#limitations)
    - [Multiple Instances](#multiple-instances)
  - [Development](#development)
    - [Contributors](#contributors)
    - [Running tests](#running-tests)

## Overview

The tomcat module lets you use Puppet to install, deploy, and configure Tomcat web services.

## Module Description

Tomcat is a Java web service provider. The tomcat module lets you use Puppet to install Tomcat, manage its configuration file, and deploy web apps to it. It supports multiple instances of Tomcat spanning multiple versions.

## Setup

### Requirements

The tomcat module requires [puppetlabs-stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) version 4.0 or newer. On Puppet Enterprise you must meet this requirement before installing the module. To update stdlib, run:

```bash
puppet module upgrade puppetlabs-stdlib
```

### Beginning with tomcat

The simplest way to get Tomcat up and running with the tomcat module is to install the Tomcat source and start the service:

```puppet
tomcat::install { '/opt/tomcat':
  source_url => 'https://www-us.apache.org/dist/tomcat/tomcat-7/v7.0.x/bin/apache-tomcat-7.0.x.tar.gz',
}
tomcat::instance { 'default':
  catalina_home => '/opt/tomcat',
}
```

> Note: look up the correct version you want to install on the [version list](http://tomcat.apache.org/whichversion.html).

## Usage

### I want to run multiple instances of multiple versions of Tomcat

```puppet
class { 'java': }

tomcat::install { '/opt/tomcat9':
  source_url => 'https://www.apache.org/dist/tomcat/tomcat-9/v9.0.x/bin/apache-tomcat-9.0.x.tar.gz'
}
tomcat::instance { 'tomcat9-first':
  catalina_home => '/opt/tomcat9',
  catalina_base => '/opt/tomcat9/first',
}
tomcat::instance { 'tomcat9-second':
  catalina_home => '/opt/tomcat9',
  catalina_base => '/opt/tomcat9/second',
}
# Change the default port of the second instance server and HTTP connector
tomcat::config::server { 'tomcat9-second':
  catalina_base => '/opt/tomcat9/second',
  port          => '8006',
}
tomcat::config::server::connector { 'tomcat9-second-http':
  catalina_base         => '/opt/tomcat9/second',
  port                  => '8081',
  protocol              => 'HTTP/1.1',
  additional_attributes => {
    'redirectPort' => '8443'
  },
}

tomcat::install { '/opt/tomcat7':
  source_url => 'http://www-eu.apache.org/dist/tomcat/tomcat-7/v7.0.x/bin/apache-tomcat-7.0.x.tar.gz',
}
tomcat::instance { 'tomcat7':
  catalina_home => '/opt/tomcat7',
}
# Change tomcat 7's server and HTTP/AJP connectors
tomcat::config::server { 'tomcat7':
  catalina_base => '/opt/tomcat7',
  port          => '8105',
}
tomcat::config::server::connector { 'tomcat7-http':
  catalina_base         => '/opt/tomcat7',
  port                  => '8180',
  protocol              => 'HTTP/1.1',
  additional_attributes => {
    'redirectPort' => '8543'
  },
}
tomcat::config::server::connector { 'tomcat7-ajp':
  catalina_base         => '/opt/tomcat7',
  port                  => '8109',
  protocol              => 'AJP/1.3',
  additional_attributes => {
    'redirectPort' => '8543'
  },
}
```

> Note: look up the correct version you want to install on the [version list](http://tomcat.apache.org/whichversion.html).

### I want to configure SSL and specify which protocols and ciphers to use

```puppet
  file { $keystore_path: 
    ensure => present,
    source => $keystore_source,
    owner => $keystore_user,
    mode => '0400',
    checksum => 'md5',
    checksum_value => $keystore_checksum,
  } ->

  tomcat::config::server::connector { "${tomcat_instance}-https":
    catalina_base         => $catalina_base,
    port                  => $https_port,
    protocol              => $http_version,
    purge_connectors      => true,
    additional_attributes => {
      'SSLEnabled'          => bool2str($https_enabled),
      'maxThreads'          => $https_connector_max_threads,
      'scheme'              => $https_connector_scheme,
      'secure'              => bool2str($https_connector_secure),
      'clientAuth'          => bool2str($https_connector_client_auth),
      'sslProtocol'         => $https_connector_ssl_protocol,
      'sslEnabledProtocols' => join($https_connector_ssl_protocols_enabled, ","),
      'ciphers'             => join($ciphers_enabled, ","),
      
      'keystorePass'        => $keystore_pass.unwrap,
      'keystoreFile'        => $keystore_path,
    },
  }
```

> See also: [SSL/TLS Configuration HOW-TO](https://tomcat.apache.org/tomcat-8.5-doc/ssl-howto.html)

### I want to deploy WAR files

Add the following to any existing installation with your own war source:
```puppet
tomcat::war { 'sample.war':
  catalina_base => '/opt/tomcat9/first',
  war_source    => '/opt/tomcat9/webapps/docs/appdev/sample/sample.war',
}
```

The name of the WAR file must end with `.war`.

The `war_source` can be a local path or a `puppet:///`, `http://`, or `ftp://` URL.

### I want to remove some configuration

Different configuration defined types will allow an ensure parameter to be passed, though the name may vary based on the defined type.

To remove a connector, for instance, the following configuration ensure that it is absent:

```puppet
tomcat::config::server::connector { 'tomcat9-jsvc':
  connector_ensure => 'absent',
  catalina_base    => '/opt/tomcat9/first',
  port             => '8080',
  protocol         => 'HTTP/1.1',
}
```

### I want to manage a Connector or Realm that already exists

Describe the Realm or HTTP Connector element using `tomcat::config::server::realm` or `tomcat::config::server::connector`, and set `purge_realms` or `purge_connectors` to `true`.

```puppet
tomcat::config::server::realm { 'org.apache.catalina.realm.LockOutRealm':
  realm_ensure => 'present',
  purge_realms => true,
}
```

Puppet removes any existing Connectors or Realms and leaves only the ones you've specified.

## Reference

See [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-tomcat/blob/master/REFERENCE.md)

## Limitations

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-tomcat/blob/master/metadata.json)

The `tomcat::config::server*` defined types require Augeas version 1.0.0 or newer.

Windows should be considered experimental and it's not a supported OS at this point. Pull requests are welcome.

### Multiple Instances

Some Tomcat packages do not let you install more than one instance. You can avoid this limitation by installing Tomcat from source.

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

For more information, see our [module contribution guide.](https://docs.puppetlabs.com/forge/contributing.html)

### Contributors

To see who's already involved, see the [list of contributors.](https://github.com/puppetlabs/puppetlabs-tomcat/graphs/contributors)

### Running tests

This project contains tests for both [rspec-puppet](http://rspec-puppet.com/) and [beaker-rspec](https://github.com/puppetlabs/beaker-rspec) to verify functionality. For in-depth information, please see their respective documentation.

Quickstart:

```bash
gem install bundler
bundle install
bundle exec rake spec
bundle exec rspec spec/acceptance
RS_DEBUG=yes bundle exec rspec spec/acceptance
```
