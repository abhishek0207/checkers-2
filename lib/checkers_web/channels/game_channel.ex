defmodule CheckersWeb.GameChannel do
    use Phoenix.Channel
    alias CheckersWeb.Game
    alias CheckersWeb.Game.Supervisor
    alias CheckersWeb.Game.Presence
    alias CheckersWeb.Game.Player
    alias CheckersWeb.Game.Square
    alias CheckersWeb.Game.PieceList
    alias CheckersWeb.Game.Piece
    alias CheckersWeb.Game.Board
    def join("game:" <> game, payload, socket) do
            player = Map.get(payload, "player")
            send(self(), {:after_join, player})
              {:ok, socket}
             end
    def handle_info({:after_join, player}, socket) do
                {:ok, _} = Presence.track(socket, player, %{
                online_at: inspect(System.system_time(:seconds))
                })
                {:noreply, socket}
    end
         def addAnotherPlayer("add_player", player, socket) do
            IO.inspect(player)
            "game:" <> gameName = socket.topic
            case Game.add_player(socket.topic, player) do
              :ok ->
                broadcast! socket, "player_added", %{message:
                "New player just joined: " <> player}
                state = Game.call_demo({:global, gameName})
                black = state.black
                red = state.red
                player1 = Player.playerName(state.player1)
                red = Enum.map(red, fn x -> 
                    {val, ""} = Atom.to_string(x)|>Integer.parse 
                        val end)
                black = Enum.map(black, fn x -> 
                    {val, ""} = Atom.to_string(x)|>Integer.parse 
                        val end)
                all = state.all
                curState = %{"player" =>  player, "player1" => player1, "black" => black, "red" => red, "all"=> all, "chat" => state.messages, "message" => "#{player} has joined, please start the game. You have red checkers"}
                curState
            end
          end
          def handle_in("newMessage", payload, socket) do
              something = Map.get(payload, "message")
              player = Map.get(payload, "player")
              "game:" <> gameName = socket.topic
              IO.puts(something)
              messages = Game.insertChatMessage({:global, gameName}, something, player )
              broadcast! socket, "new_message", %{chatmessages:
                                    messages}
              {:reply, {:ok, %{}}, socket}
          end
          def handle_in("blackWon", payload, socket) do
            "game:" <> gameName = socket.topic
            Game.setWinner({:global, gameName}, "black")
            broadcast! socket, "blackWon", %{message:
                                  "black has Won the game"}
            {:reply, {:ok, %{}}, socket}
        end
        def handle_in("redWon", payload, socket) do
            "game:" <> gameName = socket.topic
            Game.setWinner({:global, gameName}, "red")
            broadcast! socket, "redwinner", %{message:
                                  "red has won the game"}
            {:reply, {:ok, %{}}, socket}
        end
        def handle_in("giveUp", payload, socket) do
            "game:" <> gameName = socket.topic
            winner = Map.get(payload, "Player")
            Game.setWinner({:global, gameName}, winner)
            state = Game.call_demo({:global, gameName})
            IO.inspect(state)
            player1 = Player.playerName(state.player1)
            player2 = Player.playerName(state.player2)
            if(state.winner == player1) do
                broadcast! socket, "redWinner", %{winner:
                                  player1, loser: player2}
            end
            if(state.winner == player2) do
                broadcast! socket, "blackWinner", %{winner:
                                    player2, loser: player1}
            end
            {:reply, {:ok, %{}}, socket}
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
                    broadcast! socket, "player1_added", %{message:
                        curState}
                    {:reply, {:ok, curState}, socket}
                {:error, reason} ->
                        case GenServer.whereis({:global, gameName}) do
                            nil -> 
                            {:reply, {:error, "game does not exist"}, socket}
                            pid ->  
                                state = Game.call_demo({:global, gameName})
                                IO.inspect(state)
                                cond do
                                Player.playerName(state.player2) == :none ->
                                    newState = addAnotherPlayer("add_player", player, socket)
                                    broadcast! socket, "player2_added", %{message:
                                    newState}
                                    {:reply, {:ok, newState}, socket}
                                true -> 
                                    red = Game.converttoIntegerList(state.red)
                                    black = Game.converttoIntegerList(state.black)
                                    player1 = Player.playerName(state.player1)
                                    player2 = Player.playerName(state.player2)
                                    current_state = Game.Rules.show_current_state(state.fsm)
                                    next = if(current_state == :player1_turn) do
                                        "red"
                                    else 
                                        next = if(current_state == :player2_turn) do
                                            "black"
                                        else
                                            ""
                                        end
                                    end
                                    curstate = %{"player" => player , "player1"=> player1, "player2"=>player2, "red" => red, "all" => state.all, "gameStarted" => state.isGameStarted, "next" => next, "gameEnded" => state.isGameEnded, "black" => black}
                                    broadcast! socket, "new_spectator", %{message:
                                    curstate}
                                    {:reply,  {:ok, curstate}, socket}
                                end
                                
                        end
                   
                 end
          end
          def handle_in("show_subscribers", _payload, socket) do
            broadcast! socket, "subscribers", Presence.list(socket)
            {:noreply, socket}
            end
          def handle_in("checkAvailableRedJump", payload, socket) do
            "game:"<>gameName = socket.topic
            state =CheckersWeb.Game.call_demo({:global, gameName})
            player = Player.playerName(state.player1)
            curPosition = Map.get(payload, "curPosition")
            allPosition = Map.get(payload, "allPositions")
            state = Map.get(payload, "state")
            newLeft = curPosition + 14
            newRight = curPosition + 18
            cond do
            Enum.at(allPosition, newRight - 1) =="-" && Enum.at(allPosition, newRight - 10) == "b" -> 
            send(self(), {"moveRed", %{"curPosition" => curPosition, "player"=> player, "column_position" => newRight  }})
            Enum.at(allPosition, newLeft - 1) =="-" && Enum.at(allPosition, newLeft - 10) == "b" -> 
                send(self(), {"moveRed", %{"curPosition" => curPosition, "player"=> player, "column_position" => newLeft }})
            true -> state
            end
            {:noreply, socket}
          end
          def handle_in("moveRed", payload, socket) do
             "game:"<>gameName = socket.topic
              current = Map.get(payload, "curPosition")
              current = Integer.to_string(current)
              curPlayer = Map.get(payload, "player")
              newPosition = Map.get(payload, "column_position")
              jump = Map.get(payload, "jump")
              newPosition = Integer.to_string(newPosition)
              response=Game.moveRed({:global, gameName}, curPlayer, current, newPosition, jump)
              state =CheckersWeb.Game.call_demo({:global, gameName})
              case response do
                  :ok -> 
                  red = Enum.map(state.red, fn x -> 
                    {x, ""} = Atom.to_string(x) |> Integer.parse()
                    x
                end)
                black = Enum.map(state.black, fn x -> 
                    {x, ""} = Atom.to_string(x) |> Integer.parse()
                    x
                end)
                player2  = Player.playerName(state.player2)
                #get King Info
                curState = %{"player"=> curPlayer, "player2" => player2, "player1Score" => state.player1Score, "player2Score" => state.player2Score, "red" => red, "all" => state.all, "black" => black, "kings" => state.kingmap}
                  broadcast! socket, "moved_Red", %{message:
                        curState}
                    {:reply,{:ok, curState}, socket}
                    :error->
                        {:reply, :error, socket}
              end
          end
        def handle_in("moveBlack", payload, socket) do
            "game:"<>gameName = socket.topic

            current = Map.get(payload, "curPosition")
            current = Integer.to_string(current)
            curPlayer = Map.get(payload, "player")
            newPosition = Map.get(payload, "column_position")
            newPosition = Integer.to_string(newPosition)
            response=Game.moveBlack({:global, gameName}, curPlayer, current, newPosition)
            state =CheckersWeb.Game.call_demo({:global, gameName})
            case response do
                :ok -> 
                red = Enum.map(state.red, fn x -> 
                  {x, ""} = Atom.to_string(x) |> Integer.parse()
                  x
              end)
              black = Enum.map(state.black, fn x -> 
                  {x, ""} = Atom.to_string(x) |> Integer.parse()
                  x
              end)
              player1 = Player.playerName(state.player1)
              #king info added
              
                curState = %{"player" => curPlayer, "player1" => player1, "player1Score" => state.player1Score, "player2Score" => state.player2Score, "red" => red, "all" => state.all, "black" => black, "kings" => state.blackKing }
                if(length(red) == 0) do
                    
                end
                broadcast! socket, "moved_black", %{message:
                      curState}
                  {:reply,{:ok, curState}, socket}
                :error -> 
                    {:reply, :error, socket}
                  {:error, reason} ->
                      {:reply, {:error, %{reason: inspect(reason)}}, socket}
            end
        end
end