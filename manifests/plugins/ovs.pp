# Configure the quantum server to use the OVS plugin.
# This configures the plugin for the API server, but does nothing
# about configuring the agents that must also run and share a config
# file with the OVS plugin if both are on the same machine.
class quantum::plugins::ovs (
  $package_ensure      = present,
  $sql_connection      = 'sqlite:////var/lib/quantum/ovs.sqlite',
  $sql_max_retries     = 10,
  $reconnect_interval  = 2,
  $tenant_network_type = 'vlan',
  # NB: don't need tunnel ID range when using VLANs,
  # *but* you do need the network vlan range regardless of type,
  # because the list of networks there is still important
  # even if the ranges aren't specified
  $network_vlan_ranges = 'physnet1:1000:2000',
  $tunnel_id_ranges    = '1:1000'
) {

  include quantum::params
  include vswitch::ovs

  Class['vswitch::ovs'] -> Class['quantum::plugins::ovs']

  Package['quantum'] -> Package['quantum-plugin-ovs']
  Package['quantum-plugin-ovs'] -> Quantum_plugin_ovs<||>
  Quantum_plugin_ovs<||> ~> Service<| title == 'quantum-server' |>
  Package['quantum-plugin-ovs'] -> Service<| title == 'quantum-server' |>

  validate_re($sql_connection, '(sqlite|mysql|posgres):\/\/(\S+:\S+@\S+\/\S+)?')

  case $sql_connection {
    /mysql:\/\/\S+:\S+@\S+\/\S+/: {
      Class['mysql::python'] -> Class['quantum::plugins::ovs']
    }
    /postgresql:\/\/\S+:\S+@\S+\/\S+/: {
      $backend_package = 'python-psycopg2'
    }
    /sqlite:\/\//: {
      $backend_package = 'python-pysqlite2'
    }
    default: {
      fail('Unsupported backend configured')
    }
  }

  package { 'quantum-plugin-ovs':
    name   => $::quantum::params::ovs_server_package,
    ensure => $package_ensure,
  }

  quantum_plugin_ovs {
    'DATABASE/sql_connection':     value => $sql_connection;
    'DATABASE/sql_max_retries':    value => $sql_max_retries;
    'DATABASE/reconnect_interval': value => $reconnect_interval;
    'OVS/network_vlan_ranges':     value => $network_vlan_ranges;
    'OVS/tenant_network_type':     value => $tenant_network_type;
  }

  if ($tenant_network_type == 'gre') {
    quantum_plugin_ovs {
      # this is set by the plugin and the agent - since the plugin node has the agent installed
      # we rely on it setting it.
      # TODO(ijw): do something with a virtualised node
      # 'OVS/enable_tunneling':   value => 'True';
      'OVS/tunnel_id_ranges': value => $tunnel_id_ranges;
    }
  }

  if ($::osfamily == 'Redhat') {
    file { '/etc/quantum/plugin.ini':
      ensure  => symlink,
      target  => '/etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini',
      require => Package['quantum-plugin-ovs'],
    }
  }
}
