class quantum::rpc::qpid {

  include quantum::params

  Class['quantum'] -> Class['quantum::rpc::qpid']

  quantum_config {
    'DEFAULT/qpid_hostname':               value => $quantum::qpid_hostname;
    'DEFAULT/qpid_port':                   value => $quantum::qpid_port;
    'DEFAULT/qpid_username':               value => $quantum::qpid_username;
    'DEFAULT/qpid_password':               value => $quantum::qpid_password;
    'DEFAULT/qpid_heartbeat':              value => $quantum::qpid_heartbeat;
    'DEFAULT/qpid_protocol':               value => $quantum::qpid_protocol;
    'DEFAULT/qpid_tcp_nodelay':            value => $quantum::qpid_tcp_nodelay;
    'DEFAULT/qpid_reconnect':              value => $quantum::qpid_reconnect;
    'DEFAULT/qpid_reconnect_timeout':      value => $quantum::qpid_reconnect_timeout;
    'DEFAULT/qpid_reconnect_limit':        value => $quantum::qpid_reconnect_limit;
    'DEFAULT/qpid_reconnect_interval_min': value => $quantum::qpid_reconnect_interval_min;
    'DEFAULT/qpid_reconnect_interval_max': value => $quantum::qpid_reconnect_interval_max;
    'DEFAULT/qpid_reconnect_interval':     value => $quantum::qpid_reconnect_interval;
  }
}
