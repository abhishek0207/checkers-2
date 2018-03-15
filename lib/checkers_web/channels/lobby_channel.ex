defmodule CheckersWeb.LobbyChannel do
    use CheckersWeb, :channel

    def join("lobby.*", _payload, socket) do
        IO.puts("entered lobby channel")
        {:ok, socket}
    end
end