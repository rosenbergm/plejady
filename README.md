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

### Fly.io

Fly.io is a hosting service which makes it easy to deploy Elixir applications. It takes care of the entire deployment process, so you don't have to worry about it. The disadvantage is that it's not free — well, they do have a free tier, but it's not really suitable for this project.

To set up deployment to fly.io, you need to:

1. [Install](https://fly.io/docs/getting-started/installing-flyctl/) the `flyctl` CLI tool.
2. Authenticate with `flyctl auth login`.
3. Launch the app with `flyctl launch`. This will create a new app on fly.io.
    - The CLI will ask you if you want to create a database. Answer `y` (yes).
    - **IMPORTANT:* *When the CLI asks you if you want to deploy the app, answer `n` (no).
4. Set the needed environment variables with `flyctl env set <key>=<value>`. See [this section](#important-environment-variables-for-hosting-on-flyio) for a list of environment variables which need to be set.
5. Deploy the app with `flyctl deploy`.
6. Go to the fly.io dashboard and click on the "Scale" menu item. The recomended settings are:
    - **TBD**

To set up a custom domain, check out the following steps:

> In this section, we will assume that you want to use the domain `plejady.alej.cz` for the app.

1. Run `fly ips list` to get a list of available IPs.
    - This should return a list of 2 IPs – one for IPv4 and one for IPv6.
2. Write an email to Mr. Horálek (or whoever is in charge of the domain) and ask him to add **two** DNS records for the domain.
    - **A record** for the IPv4 address.
    - **AAAA record** for the IPv6 address.
3. Run `fly certs create plejady.alej.cz` to create a certificate for the domain.
    - This can take some time, so be patient. You can check on the progress using `fly certs show plejady.alej.cz`.

#### Important environment variables for hosting on fly.io

To set the environment variables, use the `flyctl env set <key>=<value>` command. The following variables need to be set:

- `GOOGLE_CLIENT_ID` - The OAuth client ID for the Google API.
- `GOOGLE_CLIENT_SECRET` - The OAuth client secret for the Google API.

### Docker

To deploy with Docker, use the provided [docker-compose.yml](docker-compose.yml) to run the app with a separate PostgreSQL database.

See [this section](#important-environment-variables-for-self-hosting) for a list of environment variables which need to be set.

#### Important environment variables for self-hosting

When starting the Docker container (**NOT** building it), you need to set the following environment variables:

- `DATABASE_URL` - The URL to the PostgreSQL database. If you're using fly.io, this is automatically set.
- `GOOGLE_CLIENT_ID` - The OAuth client ID for the Google API.
- `GOOGLE_CLIENT_SECRET` - The OAuth client secret for the Google API.
- `SECRET_KEY_BASE` - A secret key used for signing cookies. You can generate one with `mix phx.gen.secret`.
- `PHX_HOST` - The host of the application. In this case, it will be something like `plejady.alej.cz`. If you're using fly.io, this is automatically set.