defmodule CheckersWeb.Game do
    use GenServer
    alias CheckersWeb.Game.Board
    alias CheckersWeb.Game.Player
    alias CheckersWeb.Game.CheckersSet
    alias CheckersWeb.Game.Rules
    alias CheckersWeb.Game.Square
    alias CheckersWeb.Game.PieceList
    alias CheckersWeb.Game.Piece

    defstruct [
        id: nil,
        player1Id: nil,
        player2Id: nil,
        player1: nil,
        player2: nil,
        player1Joined: nil,
        player2Joined: nil,
        turns: [],
        over: false,
        winner: nil,
        color: "",
        gameBoard: nil,
        red: nil,
        black: nil,
        all: nil,
        fsm: :none,
        isGameStarted: false
      ]
      #client_side
      def start_link(gameName, player) when not is_nil gameName do
        IO.puts("entered Gen Server")
        IO.puts("game name is #{gameName}")
        IO.puts("player name is #{player}")
        GenServer.start_link(__MODULE__,  %{gameName: gameName, player: player }, name: {:global, gameName})
      end
      #server_side
      def init(argMap) do
        IO.puts("player is ")
        player = Map.get(argMap, :player)
        gameName = Map.get(argMap, :gameName)
        IO.puts(player)
        IO.puts(gameName)
        {:ok, board} = Board.create()
        {:ok, player1} = Player.create(player, board)
        {:ok, player2} = Player.create(board)
        Player.setPieces(player1, board, "red")
        newList = PieceList.getList(Player.getColorSet(player1))
        newList = Enum.map(newList, fn x -> Piece.getPosition(x) end)
        newList = Enum.map(newList, fn x-> Board.getBoardPosition(board, x) end)
        allPos = Board.getAllPositions(board)
        {:ok, fsm} = Rules.start_link()
        {:ok, %__MODULE__{id: gameName, isGameStarted: true, player1: player1, player1Joined: true, player2: player2, red: newList, gameBoard: board, fsm: fsm, all: allPos}}
      end

    def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}
    
    def add_player(channel_topic, name) when name != nil
     do
      "game:"<>gameName = channel_topic
      GenServer.call({:global, gameName}, {:addPlayer, name})
    end

     def handle_call({:addPlayer, name}, _from, state) do
      newState = Rules.add_player(state.fsm)|> add_player_reply(state, name)
      Rules.player1_turn(state.fsm) 
      {:reply, :ok, newState}
     end

     def add_player_reply(:ok, state, name) do
      Player.setName(state.player2, name)
      Player.setPieces(state.player2, state.gameBoard, "black")
      newList = PieceList.getList(Player.getColorSet(state.player2))
      newList = Enum.map(newList, fn x -> Piece.getPosition(x) end)
      newList = Enum.map(newList, fn x-> Board.getBoardPosition(state.gameBoard, x) end)
      allPos = Board.getAllPositions(state.gameBoard)
      IO.inspect(newList)
      state = Map.put(state, :black, newList)
      state = Map.put(state, :all, allPos)
      state
     end

     def add_player_reply(reply, state, _name) do
      {:reply, reply, state}
     end
     def call_demo(pid) do
       GenServer.call(pid, :demo)
     end

     def handle_call(:demo, _from, state) do
      {:reply, state, state}
      end

      def setRedcheckerslist(pid, player, boardpid) do
        GenServer.call(pid, {:setRedPieceList, player, boardpid})
      end

      def handle_call({:setRedPieceList, player, board}, _from, state) do
         Player.setPieces(player, board,"red")
         {:reply, :ok, state}
      end
      def setBlackcheckerslist(pid, player, boardpid) do
        GenServer.call(pid, {:setBlackPieceList, player, boardpid})
      end
      def handle_call({:setBlackPieceList, player, board}, _from, state) do
        Player.setPieces(player, board,"black")
        {:reply, :ok, state}
     end
      def moveRed(pid, player, curPos, newPosition) do
        GenServer.call(pid, {:moveRed,  player, curPos, newPosition})
      end
      def moveBlack(pid, player, curPosition, newPosition) do
        GenServer.call(pid, {:moveBlack,  player, curPosition, newPosition})
      end

      def handle_call({:moveRed, player, current, newPosition}, _from, state) do
        #will just update square pids in pieces
        IO.puts("moving red is ")
        IO.puts("new Position is ")
        IO.inspect(newPosition)
        IO.puts("#{player}")
        IO.puts("player 1 is")
        IO.puts("#{Process.alive?(state.player1)}")
        IO.puts(Player.tostring(state.player1))
        playerName = player
        IO.puts("#{playerName}")
        newState = movePiece(:ok, player, current, newPosition, state, "red")
        {:reply, :ok, newState} 
      end

      def handle_call({:moveBlack, player, curPosition, newPosition}, _from, state) do
        #will just update square pids in pieces
        newState = movePiece(:ok, player, curPosition, newPosition, state, "black")
        {:reply, :ok, newState} 
      end

      def movePiece(:ok, player, curPosition, newPosition, state, color) do
        curPosition =  String.to_atom(curPosition)
        newPosition =  String.to_atom(newPosition)
        player2Name = Player.playerName(state.player2)
        curSquarepid = Board.getSquare(state.gameBoard, curPosition)
        newSquarepid = Board.getSquare(state.gameBoard, newPosition)
        piecePid  =    Square.getPiecePid(curSquarepid)
        player1Name = Player.playerName(state.player1)
        Square.setPiecePid(newSquarepid, piecePid)
        Square.removePiece(curSquarepid)
        newstate = cond  do
        player == player1Name && color == "red" -> 
          IO.puts("entered in the red condition")  
          newList = PieceList.getList(Player.getColorSet(state.player1))
          oldRed = state.red
          newRed = Enum.map(oldRed, fn x -> 
            z = newPosition
            y = curPosition
            if(x==y) do
              z
            else 
              x
            end
          end)
        PieceList.update_list(Player.getColorSet(state.player1), newRed)
        #logic for diagonal movement
        {intcurPosition, ""}= Atom.to_string(curPosition) |> Integer.parse
        {intnewPosition, ""}= Atom.to_string(newPosition) |> Integer.parse
        diff = abs(intcurPosition - intnewPosition)
        IO.puts("diff is")
        IO.puts("#{diff}")
        newstate = if(diff == 14 || diff == 18) do
          IO.puts("called diagnoal")
         computeDiagonalPieceMovement(intcurPosition, intnewPosition, state, color, diff)
        else
          state
        end
        
        newstate = Map.put(newstate, :red, newRed)
        allPos = Board.getAllPositions(state.gameBoard)
        newstate = Map.put(newstate, :all, allPos)
        newstate
        player == player2Name && color == "black" -> 
          IO.puts("entered black party") 
          newList = PieceList.getList(Player.getColorSet(state.player2))
          oldBlack = state.black
          newBlack = Enum.map(oldBlack, fn x -> 
            z = newPosition
            y = curPosition
            if(x==y) do
              z
            else 
              x
            end
          end)
        PieceList.update_list(Player.getColorSet(state.player2), newBlack)
        IO.puts("new Black is")
        IO.inspect(newBlack)
        #logic for diagonal movement
        {intcurPosition, ""}= Atom.to_string(curPosition) |> Integer.parse
        {intnewPosition, ""}= Atom.to_string(newPosition) |> Integer.parse
        diff = abs(intcurPosition - intnewPosition)
        IO.puts("diff is")
        IO.puts("#{diff}")
        newstate = if(diff == 14 || diff == 18) do
          IO.puts("called diagnoal")
         computeDiagonalPieceMovement(intcurPosition, intnewPosition, state, color, diff)
        else
          state
        end
        newstate = Map.put(newstate, :black, newBlack)
        allPos = Board.getAllPositions(state.gameBoard)
        newstate = Map.put(newstate, :all, allPos)
        newstate
        true -> state 
        end  
      end
      def computeDiagonalPieceMovement(intcurPosition, intnewPosition, state, color, diff) do
        IO.puts("entered diagnoal")
        cond do
        color == "red" -> 
          blackPositions = state.black
          atNextPos = cond do
            diff == 14 -> 
                atNextPos = Integer.to_string(intcurPosition + 7) |> String.to_atom
            diff == 18  ->
              Integer.to_string(intcurPosition + 9) |> String.to_atom
            true -> :"n"
          end
        blackPositions = if(atNextPos!= :"n") do
        blackSquare = Board.getSquare(state.gameBoard, atNextPos)
        Square.removePiece(blackSquare)
        indexOfSelected = Enum.find_index(blackPositions, fn(x) -> x == atNextPos end)
        List.delete_at(blackPositions, indexOfSelected)
          else
              blackPositions
        end
        Map.put(state, :black, blackPositions)
        color == "black" -> 
          IO.puts("entered diagnoal black")
          redPositions = state.red
          atNextPos = cond do
            diff == 14 -> 
                atNextPos = Integer.to_string(intcurPosition - 7) |> String.to_atom
            diff == 18  ->
              Integer.to_string(intcurPosition - 9) |> String.to_atom
            true -> :"n"
          end
        redPositions = if(atNextPos!= :"n") do
        redSquare = Board.getSquare(state.gameBoard, atNextPos)
        Square.removePiece(redSquare)
        indexOfSelected = Enum.find_index(redPositions, fn(x) -> x == atNextPos end)
        List.delete_at(redPositions, indexOfSelected)
          else
             redPositions
        end
        Map.put(state, :red, redPositions)
        true -> state
      end
      end

      def movePiece(:error, _player, _curPosition, _newPosition, state) do
        {:reply, :error, state}
      end

      def stop(pid) do
        GenServer.cast(pid, :stop)
        end
      def handle_cast(:stop, state) do
          {:stop, :normal, state}
      end
    end