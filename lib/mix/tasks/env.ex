defmodule Mix.Tasks.Env do
  use Mix.Task

  @dev_secret "config/dev.secret.exs"
  @prod_secret "config/prod.secret.exs"

  def run(_) do
    IO.puts(
      "Vítej v konfigurátoru prostředí aplikace Plejády.\n\nTento průvodce tě provede nastavením celého systému před prvním spuštěním a zajistí, aby následné nasazení proběhlo hladce.\n"
    )

    IO.puts(
      "Pokud se vyskytne problém, otevři issue na GitHubu (https://github.com/rosenbergm/plejady), určitě ti poradím!"
    )

    IO.puts("Tak se na to pojďme podívat... Nejdříve dáme do kupy prostředí pro vývoj.")

    if File.exists?(@dev_secret) do
      IO.puts("Koukám, že vývojové prostředí už nastavené máš... Pojďme dále.")
    else
      IO.puts("Vidím, že vyvojové prostředí nastavené nemáš. Pojďme to nastavit!")

      IO.puts(
        "Budu od tebe potřebovat pár informací. Konkrétně se jedná o přístupové údaje k databázi a údaje pro zprostředkování Google přihlašování. Pokud tyto údaje nemáš, koukni do README jak je získat."
      )

      continue =
        IO.gets(
          "Chceš pokračovat? Pokud ano, stiskni enter. Pokud ne, zmáčkni jakékoli jiné tlačítko. Neboj, k tomuto kroku se znovu dostaneš;)"
        )

      unless continue == "\n" do
        System.halt()
      end

      hostname = IO.gets("Jaká je adresa databáze? ") |> String.trim()
      database = IO.gets("Jaké je jméno databáze? ") |> String.trim()
      username = IO.gets("Jaké je uživatelské jméno k přístupu do databáze? ") |> String.trim()
      password = IO.gets("Jaké je heslo k přístupu do databáze? ") |> String.trim()

      client_id = IO.gets("Jaké je Client ID od Google OAuth? ") |> String.trim()
      client_secret = IO.gets("Jaký je Client Secret od Google OAuth? ") |> String.trim()

      IO.puts("Paráda, zapisuji do config/dev.secret.exs!")

      File.write(@dev_secret, """
      import Config

      config :elixir_auth_google,
        client_id: "#{client_id}",
        client_secret: "#{client_secret}"

      config :plejady, Plejady.Repo,
        username: "#{username}",
        password: "#{password}",
        hostname: "#{hostname}",
        database: "#{database}",
        show_sensitive_data_on_connection_error: true,
        pool_size: 10
      """)

      IO.puts("Zapsáno!")
    end

    IO.puts(
      "Paráda! Všechno nastaveno. Teď můžeš spustit\n\nmix phx.server\n\npro rozběhnutí serveru ve vývojářském módu."
    )
  end
end
