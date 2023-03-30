import Config

# Configure your database
config :plejady, Plejady.Repo,
  # ! CHANGE THIS
  username: "USERNAME",
  # ! CHANGE THIS
  password: "PASSWORD",
  # ! CHANGE THIS
  hostname: "HOSTNAME",
  # ! CHANGE THIS
  database: "DATABASE_NAME",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

# Configure authentication
config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  # ! CHANGE THIS
  client_id: "INSERT_GOOGLE_CLIENT_ID_HERE",
  # ! CHANGE THIS
  client_secret: "INSERT_GOOGLE_CLIENT_SECRET_HERE"
