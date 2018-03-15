defmodule CheckersWeb.LobbyChannels do
    use CheckersWeb, :channel
    alias Checkers.Game.Supervisor, as: GameSupervisor

    def join("lobby:" <> gameName, _payload, socket) do
        IO.puts("entered lobby channel")
        curState = Checkers.GameLogic.initialState()
        IO.inspect(curState)
        {:ok,%{"curState" => curState}, socket}
    end

    def handle_in("current_games", _params, socket) do
        {:reply, {:ok, %{games: GameSupervisor.current_games}}, socket}
      end

    def handle_in("moveRed", %{"state" => state, "column_position" => column_position}, socket) do
        curState = Checkers.GameLogic.redClick(state, column_position)
        {:reply, {:ok, %{"curState" => curState}}, socket}
      end
    def handle_in("moveBlack", %{"state" => state, "column_position" => column_position}, socket) do
        curState = Checkers.GameLogic.blackClick(state, column_position)
        {:reply, {:ok, %{"curState" => curState}}, socket}
     end

    def handle_in("new_game", _params, socket) do
        game_id = Checkers.generate_game_id
        GameSupervisor.create_game(game_id)
        {:reply, {:ok, %{game_id: game_id}}, socket}
      end

      def broadcast_current_games do
        CheckersWeb.Endpoint.broadcast("lobby", "update_games", %{games: GameSupervisor.current_games})
      end
end