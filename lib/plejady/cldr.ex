defmodule Plejady.Cldr do
  @moduledoc """
  A module providing Internationalization with a cldr-based API.
  """

  use Cldr,
    locales: ["cs"],
    default_locale: "cs",
    providers: [Cldr.DateTime, Cldr.Number, Cldr.Calendar]
end
