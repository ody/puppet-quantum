class quantum::rpc::rabbit {

  include quantum::params

  Class['quantum'] -> Class['quantum::rpc::rabbit']

  if ! $rabbit_password {
    fail("When rpc_backend is rabbitmq, you must set rabbit password")
  }

  if $rabbit_hosts {
    quantum_config { 'DEFAULT/rabbit_host':  ensure => absent }
    quantum_config { 'DEFAULT/rabbit_port':  ensure => absent }
    quantum_config { 'DEFAULT/rabbit_hosts': value => join($quantum::rabbit_hosts, ',') }
  } else {
    quantum_config { 'DEFAULT/rabbit_host':  value => $quantum::rabbit_host }
    quantum_config { 'DEFAULT/rabbit_port':  value => $quantum::rabbit_port }
    quantum_config { 'DEFAULT/rabbit_hosts': value => "${quantum::rabbit_host}:${quantum::rabbit_port}" }
  }

  if size($quantum::rabbit_hosts) > 1 {
    quantum_config { 'DEFAULT/rabbit_ha_queues': value => 'true' }
  } else {
    quantum_config { 'DEFAULT/rabbit_ha_queues': value => 'false' }
  }

  quantum_config {
    'DEFAULT/rabbit_userid':       value => $quantum::rabbit_user;
    'DEFAULT/rabbit_password':     value => $quantum::rabbit_password;
    'DEFAULT/rabbit_virtual_host': value => $quantum::rabbit_virtual_host;
  }
}

