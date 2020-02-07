import Config

IO.puts(Mix.env())

import_config "#{Mix.env()}.exs"
