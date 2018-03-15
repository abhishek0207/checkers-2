defmodule Checkers do
  use Application
  @moduledoc """
  Checkers keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  
 
  def generate_player_id do
    id_length =  Application.get_env(:checkers, :id_length)
    IO.puts(id_length)
    id_length
    |> :crypto.strong_rand_bytes
    |> Base.url_encode64()
    |> binary_part(0, id_length)
  end
end
