# Plejady

An event management system for a school event.

## Development

1. [Install](https://elixir-lang.org/install.html) Elixir
2. Run `mix deps.get` to install dependencies
3. Run `mix env` for an interactive guide to setup the development environment.
4. Run `mix phx.server` to start a local server!

> ⚠️ You need to have a PostgreSQL database running on your local machine.

## Deployment

You can either deploy to fly.io (easy-ish) or self-host the entire project. If you don't have a server, then go for fly.io or contact Martin Rosenberg (nitram.rosenberg@gmail.com), he will lend you one.

### Docker

To deploy with Docker, use the provided [docker-compose.yml](docker-compose.yml) to run the app with a separate PostgreSQL database.

**IMPORTANT:** Change the database password and SECRET_KEY_BASE (which you can generate with `mix phx.gen.secret`). 
