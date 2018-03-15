defmodule CheckersWeb.Game do
    use GenServer
    alias CheckersWeb.Game.Board
    alias CheckersWeb.Game.Player
    defstruct [
        id: nil,
        player1: nil,
        player2: nil,
        turns: [],
        over: false,
        winner: nil,
        color: ""
      ]
      #client_side
      def start_link(name) when not is_nil name do
        GenServer.start_link(__MODULE__, id, name: ref(id))
      end
      #server_side
      def init(id) do
        {:ok, player1} = Player.start_link(id)
        {:ok, player2} = Player.start_link()
        {:ok, %__MODULE__{id: id, player1: player1, player2: player2}}
      end

      defp ref(id), do: {:global, {:game, id}}

      defp try_call(id, message) do
        case GenServer.whereis(ref(id)) do
          nil ->
            {:error, "Game does not exist"}
          pid ->
            GenServer.call(pid, message)
        end
    end
    def join(id, player_id, pid), do: try_call(id, {:join, player_id, pid}) #here try call is the client function
    #used for handling calls on the server
 
    def handle_call({:join, player_id, pid}, _from, game) do
        cond do
          game.player1Id != nil and game.player2Id != nil ->
            {:reply, {:error, "No more players allowed"}, game}
          Enum.member?([game.player1Id, game.player2Id], player_id) ->
            {:reply, {:ok, self}, game}
          true ->
            Process.flag(:trap_exit, true)
            Process.monitor(pid)
    
            #{:ok, board_pid} = create_board(player_id)
            {:ok, board_pid} =  create_checkers(player_id)
            Process.monitor(board_pid)
    
            game = add_player(game, player_id)
    
            {:reply, {:ok, self}, game}
        end
      end
      defp create_checkers(player_id), do: Board.create(player_id)

      defp add_player(%__MODULE__{player1Id: nil} = game, player_id), do: %{game | player1Id: player_id}

     defp add_player(%__MODULE__{player2Id: nil} = game, player_id), do: %{game | player2Id: player_id}
     
     def handle_info(:first, state) do
       IO.puts("tje message is handled")
       {:noreply, state}
     end
end