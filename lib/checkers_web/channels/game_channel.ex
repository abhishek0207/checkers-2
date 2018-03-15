defmodule CheckersWeb.GameChannel do
    use Phoenix.Channel
    alias CheckersWeb.Game
    def join("game:" <> game_id, _message, socket) do
        player_id = socket.assigns.player_id
        case Game.join(game_id, player_id, socket.channel_pid) do
            {:ok, _pid} ->
                {:ok, assign(socket, :game_id, game_id)}
            {:error, reason} -> 
                {:error, %{reason: reason}}
        end
    end

    def handle_in("game:joined", _message, socket) do
        player_id = socket.assigns.player_id
        board = Board.get_opponents_data(player_id)
    
        broadcast! socket, "game:player_joined", %{player_id: player_id, board: board}
        {:noreply, socket}
      end
end