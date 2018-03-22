defmodule CheckersWeb.GameChannel do
    use Phoenix.Channel
    alias CheckersWeb.Game
    alias CheckersWeb.Game.Supervisor
    alias CheckersWeb.Game.Presence
    alias CheckersWeb.Game.Player
    def join("game:" <> game, payload, socket) do
            player = Map.get(payload, "player")
            IO.puts("#{player} joined the channel")
                {:ok, socket}
             end
         def handle_info({:after_join, player}, socket) do
            IO.puts("entered after join clause")
            "game:" <> gameName = socket.topic
            state = Game.call_demo({:global, gameName})
            broadcast! socket, "add_player", %{player: player}
            {:noreply, socket}
          end

         def handle_in("add_player", player, socket) do
            IO.puts("entereded add player")
            IO.inspect(player)
            "game:" <> gameName = socket.topic
            case Game.add_player(socket.topic, player) do
              :ok ->
                broadcast! socket, "player_added", %{message:
                "New player just joined: " <> player}
                state = Game.call_demo({:global, gameName})
                black = state.black
                red = state.red
                red = Enum.map(red, fn x -> 
                    {val, ""} = Atom.to_string(x)|>Integer.parse 
                        val end)
                black = Enum.map(black, fn x -> 
                    {val, ""} = Atom.to_string(x)|>Integer.parse 
                        val end)
                all = state.all
                curState = %{"player" =>  player, "black" => black, "red" => red, "all"=> all}
                broadcast! socket, "player2_added", %{message:
                curState}
                {:reply, {:ok, curState}, socket}
              {:error, reason} ->
                {:reply, {:error, %{reason: inspect(reason)}}, socket}
              :error -> {:reply, :error, socket}
            end
          end
          def handle_in("new_game", payload, socket) do
            "game:"<>gameName = socket.topic
            player = Map.get(payload, "playerName")
            IO.puts("first one is #{player}")
            case Supervisor.start_game(gameName, player) do
                {:ok, pid} -> 
                    state = CheckersWeb.Game.call_demo(pid)
                    playerName = Player.playerName(state.player1)
                    red = state.red
                    gameStarted = state.isGameStarted
                    IO.puts("#{gameStarted}")
                    red = Enum.map(red, fn x -> 
                        {val, ""} = Atom.to_string(x)|>Integer.parse 
                            val end)
                    all = state.all
                    curState = %{"player" =>  playerName, "red" => red, "all" => all, "gameStarted" => gameStarted, "black" => []}
                    socket = socket |> assign(:curState, curState)
                    IO.inspect(socket.assigns[:curState])
                    broadcast! socket, "player1_added", %{message:
                        curState}
                    {:reply, {:ok, curState}, socket}
                    {:error, reason} ->
                    {:reply, {:error, %{reason: inspect(reason)}}, socket}
                 end
          end
          def handle_in("moveRed", payload, socket) do
             "game:"<>gameName = socket.topic
              current = Map.get(payload, "curPosition")
              current = Integer.to_string(current)
              curPlayer = Map.get(payload, "player")
              newPosition = Map.get(payload, "column_position")
              newPosition = Integer.to_string(newPosition)
              response=Game.moveRed({:global, gameName}, curPlayer, current, newPosition)
              case response do
                  :ok -> 
                  state =CheckersWeb.Game.call_demo({:global, gameName})
                  red = Enum.map(state.red, fn x -> 
                    {x, ""} = Atom.to_string(x) |> Integer.parse()
                    x
                end)
                black = Enum.map(state.black, fn x -> 
                    {x, ""} = Atom.to_string(x) |> Integer.parse()
                    x
                end)
                  curState = %{"red" => red, "all" => state.all, "black" => black}
                  broadcast! socket, "moved_Red", %{message:
                        curState}
                    {:reply,{:ok, curState}, socket}
                    {:error, reason} ->
                        {:reply, {:error, %{reason: inspect(reason)}}, socket}
              end
          end
        def handle_in("moveBlack", payload, socket) do
            "game:"<>gameName = socket.topic
            current = Map.get(payload, "curPosition")
            current = Integer.to_string(current)
            curPlayer = Map.get(payload, "player")
            newPosition = Map.get(payload, "column_position")
            newPosition = Integer.to_string(newPosition)
            IO.puts("enterede move Black")
            response=Game.moveBlack({:global, gameName}, curPlayer, current, newPosition)
            case response do
                :ok -> 
                state =CheckersWeb.Game.call_demo({:global, gameName})
                red = Enum.map(state.red, fn x -> 
                  {x, ""} = Atom.to_string(x) |> Integer.parse()
                  x
              end)
              black = Enum.map(state.black, fn x -> 
                  {x, ""} = Atom.to_string(x) |> Integer.parse()
                  x
              end)
                curState = %{"red" => red, "all" => state.all, "black" => black}
                broadcast! socket, "moved_black", %{message:
                      curState}
                  {:reply,{:ok, curState}, socket}
                  {:error, reason} ->
                      {:reply, {:error, %{reason: inspect(reason)}}, socket}
            end
        end
end