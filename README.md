# Plejady

An event management system for a yearly school event.

## Development

1. [Install](https://elixir-lang.org/install.html) Elixir
2. Follow [these instructions](#configuring-the-application) for configuring the app.
3. Run `mix deps.get` to install dependencies
4. Run `mix phx.server` to start a local server!

> ⚠️ You need to have a PostgreSQL database running on your local machine.

## Configuring the application

Before installing dependencies, you need to properly configure the application. This is done by creating a `dev.secret.exs` file in the `config` directory of the project. 

1. Copy the `dev.secret.exs.example` file to `config/dev.secret.exs`
2. Change the values in the file to match your local setup.
    - `client_id` and `client_secret` are the OAuth credentials for the Google API. You can get them [here](https://console.developers.google.com/apis/credentials). Make sure you select the right project.
    - There are also database credentials. You need to change them to match your local setup. If you're using Docker to host your local database, you can use the default values.

## Deployment

You can either deploy to fly.io (easy-ish) or self-host the entire project. If you don't have a server, then go for fly.io or contact Martin Rosenberg (nitram.rosenberg@gmail.com), he will lend you one.

### Important environment variables

When starting the Docker container (**NOT** building it), you need to set the following environment variables:

- `DATABASE_URL` - The URL to the PostgreSQL database. If you're using fly.io, this is automatically set.
- `GOOGLE_CLIENT_ID` - The OAuth client ID for the Google API.
- `GOOGLE_CLIENT_SECRET` - The OAuth client secret for the Google API.
- `SECRET_KEY_BASE` - A secret key used for signing cookies. You can generate one with `mix phx.gen.secret`.
- `PHX_HOST` - The host of the application. In this case, it will be something like `plejady.alej.cz`. If you're using fly.io, this is automatically set.

### Docker

To deploy with Docker, use the provided [docker-compose.yml](docker-compose.yml) to run the app with a separate PostgreSQL database.
