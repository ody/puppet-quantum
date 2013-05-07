#
# Used to grant access to the quantum mysql DB
#
define quantum::db::mysql::host_access (
  $user,
  $password,
  $database
) {

  database_user { "${user}@${name}":
    password_hash => mysql_password($password),
    provider      => 'mysql',
    require       => Database[$database],
  }

  # TODO figure out which privileges to grant.
  database_grant { "${user}@${name}/${database}":
    privileges => 'all',
    provider   => 'mysql',
    require    => Database_user["${user}@${name}"],
  }
}
