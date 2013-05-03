class quantum (
  $enabled                     = true,
  $package_ensure              = 'present',
  $verbose                     = 'False',
  $debug                       = 'False',
  $bind_host                   = '0.0.0.0',
  $bind_port                   = '9696',
  $core_plugin                 = 'quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2',
  $auth_strategy               = 'keystone',
  $base_mac                    = 'fa:16:3e:00:00:00',
  $mac_generation_retries      = 16,
  $dhcp_lease_duration         = 120,
  $allow_bulk                  = 'True',
  $allow_overlapping_ips       = 'False',
  $control_exchange            = 'quantum',
  $rpc_backend                 = 'quantum.openstack.common.rpc.impl_kombu',
  $rabbit_password             = false,
  $rabbit_host                 = 'localhost',
  $rabbit_hosts                = undef,
  $rabbit_port                 = '5672',
  $rabbit_user                 = 'guest',
  $rabbit_virtual_host         = '/',
  $qpid_hostname               = 'localhost',
  $qpid_port                   = '5672',
  $qpid_username               = 'guest',
  $qpid_password               = 'guest',
  $qpid_heartbeat              = 60,
  $qpid_protocol               = 'tcp',
  $qpid_tcp_nodelay            = true,
  $qpid_reconnect              = true,
  $qpid_reconnect_timeout      = 0,
  $qpid_reconnect_limit        = 0,
  $qpid_reconnect_interval_min = 0,
  $qpid_reconnect_interval_max = 0,
  $qpid_reconnect_interval     = 0
) {

  include quantum::params

  Package['quantum'] -> Quantum_config<||>

  File {
    require => Package['quantum'],
    owner   => 'root',
    group   => 'quantum',
    mode    => '0750',
  }

  file { '/etc/quantum': ensure  => directory }

  file { '/etc/quantum/quantum.conf': mode  => '0640' }

  file { '/etc/quantum/rootwrap.conf':
    ensure  => present,
    source  => "puppet:///modules/${module_name}/rootwrap.conf",
  }

  package { 'quantum':
    name   => $::quantum::params::package_name,
    ensure => $package_ensure
  }

  quantum_config {
    'DEFAULT/verbose':                value => $verbose;
    'DEFAULT/debug':                  value => $debug;
    'DEFAULT/bind_host':              value => $bind_host;
    'DEFAULT/bind_port':              value => $bind_port;
    'DEFAULT/auth_strategy':          value => $auth_strategy;
    'DEFAULT/core_plugin':            value => $core_plugin;
    'DEFAULT/base_mac':               value => $base_mac;
    'DEFAULT/mac_generation_retries': value => $mac_generation_retries;
    'DEFAULT/dhcp_lease_duration':    value => $dhcp_lease_duration;
    'DEFAULT/allow_bulk':             value => $allow_bulk;
    'DEFAULT/allow_overlapping_ips':  value => $allow_overlapping_ips;
    'DEFAULT/control_exchange':       value => $control_exchange;
    'DEFAULT/rootwrap_conf':          value => '/etc/quantum/rootwrap.conf';
    'DEFAULT/rpc_backend':            value => $rpc_backend;
  }

  case $rpc_backend
    'quantum.openstack.common.rpc.impl_kombu': { include quantum::rpc::rabbit }
    'quantum.openstack.common.rpc.impl_qpid':  { include quantum::rpc::qpid   }
  }
}
