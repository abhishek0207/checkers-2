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
        isGameStarted: false,
        messages: [],
        jump: false,
        kings: [],
        kingmap: Map.new,
        blackKing: Map.new
      ]
      #client_side
      def start_link(gameName, player) when not is_nil gameName do
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
        {:ok, fsm} = Rules.start_link(player)
        {:ok, %__MODULE__{id: gameName, isGameStarted: true, player1: player1, player1Joined: true, player2: player2, red: newList, gameBoard: board, fsm: fsm, all: allPos}}
      end

    def via_tuple(name), do: {:via, Registry, {Registry.Game, name}}
    
    def add_player(channel_topic, name) when name != nil
     do
      "game:"<>gameName = channel_topic
      GenServer.call({:global, gameName}, {:addPlayer, name})
    end

     def handle_call({:addPlayer, name}, _from, state) do
      newState = Rules.add_player(state.fsm, name)|> add_player_reply(state, name)
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
     def insertChatMessage(pid, message, player) do
       GenServer.call(pid, {:chat, player, message})
     end
     def handle_call({:chat, player, message}, _from, state) do
          chatMessage = state.messages
          IO.puts(player)
          IO.puts(message)
          newMessage = player <> " : " <> message
          chatMessages = chatMessage  ++ [newMessage]
          state = Map.put(state, :messages, chatMessages)
          {:reply, state.messages, state}
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
      def moveRed(pid, player, curPos, newPosition, jump) do
        GenServer.call(pid, {:moveRed,  player, curPos, newPosition, jump})
      end
      def moveBlack(pid, player, curPosition, newPosition) do
        GenServer.call(pid, {:moveBlack,  player, curPosition, newPosition})
      end

      def handle_call({:moveRed, player, current, newPosition, jump}, _from, state) do
        #will just update square pids in pieces
        cond do
        jump == true -> newState = movePiece(:ok, player, current, newPosition, state, "red")
        {:reply, :ok, newState} 
        true ->
        turn = Rules.move_red(state.fsm, player)
        case turn do
          :ok ->  
            newState = movePiece(:ok, player, current, newPosition, state, "red")
            IO.inspect("state in red call is")
            IO.inspect(newState)
              {:reply, :ok, newState} 
          :error ->
              {:reply, :error, state}
            end
        end
      end

      def handle_call({:moveBlack, player, curPosition, newPosition}, _from, state) do
        #will just update square pids in pieces
        IO.inspect(state.fsm)
        IO.puts("state in black is")
        IO.inspect(state)
        turn = Rules.move_black(state.fsm, player)
        case turn do
        :ok -> 
          newState = movePiece(:ok, player, curPosition, newPosition, state, "black")
        {:reply, :ok, newState} 
        :error -> {:reply, :error, state}
        end
        
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
        
        #PieceList.update_list(Player.getColorSet(state.player1), newRed)
        #logic for diagonal movement
        {intcurPosition, ""}= Atom.to_string(curPosition) |> Integer.parse
        {intnewPosition, ""}= Atom.to_string(newPosition) |> Integer.parse
        
        diff = intcurPosition - intnewPosition
        if(intnewPosition > 56) do
          Piece.makeKing(piecePid)
        end
        newstate = if(diff == 14 || diff == -14 || diff == -18 || diff == 18) do
         computeDiagonalPieceMovement(intcurPosition, intnewPosition, state, color, diff)
        else
          state
        end
        newstate = Map.put(newstate, :red, newRed)
        IO.inspect(newstate)
        allPos = Board.getAllPositions(state.gameBoard)
        newstate = Map.put(newstate, :all, allPos)
        listOfKings = Enum.filter(newstate.red, fn x ->
          #these are the positions on the board
          squarePid = Board.getSquare(state.gameBoard, x)
          piecePid = Square.getPiecePid(squarePid)
          Piece.king?(piecePid)
        end)
        IO.puts("kings are")
        IO.inspect(listOfKings)
        
          kingmap =%{}  
          listMap =Enum.map(listOfKings, fn x -> 
          index = Enum.find_index(newstate.red, fn(y) -> x == y end)
          Map.put(kingmap, index, x)
        end)

        IO.puts("list map is ")
        IO.inspect(listMap)
        
        kingmap = if(length(listMap) > 0) do
          kingmap = Enum.reduce(listMap, fn x, y ->
            Map.merge(x, y, fn _k, v1, v2 -> v2 ++ v1 end)
         end)
        else 
          newstate.kingmap
        end
        IO.inspect(listMap)
        IO.inspect(kingmap)
        newstate = Map.put(newstate, :kingmap, kingmap)
        newstate
        
        ##black started 
        player == player2Name && color == "black" -> 
          IO.puts("State in black is")
          IO.inspect(state)
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
        #PieceList.update_list(Player.getColorSet(state.player2), newBlack)
        #logic for diagonal movement
        {intcurPosition, ""}= Atom.to_string(curPosition) |> Integer.parse
        {intnewPosition, ""}= Atom.to_string(newPosition) |> Integer.parse
        diff = intcurPosition - intnewPosition
        if(intnewPosition <=8) do
          Piece.makeKing(piecePid)
        end
        newstate = if(diff == 14 || diff == -14 || diff == -18 || diff == 18) do
         computeDiagonalPieceMovement(intcurPosition, intnewPosition, state, color, diff)
        else
          state
        end

        newstate = Map.put(newstate, :black, newBlack)
        allPos = Board.getAllPositions(state.gameBoard)
        newstate = Map.put(newstate, :all, allPos)

        #king logic
        #blackKing = newstate.blackKing
        #if(blackKing == nil) do
         # blackKing = %{}
         #end

         listOfKings = Enum.filter(newstate.black, fn x ->
          #these are the positions on the board
          squarePid = Board.getSquare(state.gameBoard, x)
          piecePid = Square.getPiecePid(squarePid)
          Piece.king?(piecePid)
        end)
        IO.puts("kings are")
        IO.inspect(listOfKings)
        
          blackKing =%{}  
          listMap =Enum.map(listOfKings, fn x -> 
          index = Enum.find_index(newstate.black, fn(y) -> x == y end)
          Map.put(blackKing, index, x)
        end)

        IO.puts("list map is ")
        IO.inspect(listMap)
        
        blackKing = if(length(listMap) > 0) do
          blackKing = Enum.reduce(listMap, fn x, y ->
            Map.merge(x, y, fn _k, v1, v2 -> v2 ++ v1 end)
         end)
        else 
          newstate.blackKing
        end
        IO.inspect(listMap)
        IO.inspect(blackKing)
        newstate = Map.put(newstate, :blackKing, blackKing)
        newstate
        true -> state 
        end  
      end
     
      def computeDiagonalPieceMovement(intcurPosition, intnewPosition, state, color, diff) do
        cond do
        color == "red" -> 
          blackPositions = state.black
          atNextPos = cond do
            diff == -14 -> 
                atNextPos = Integer.to_string(intcurPosition + 7) |> String.to_atom
            diff == 14 -> 
                  atNextPos = Integer.to_string(intcurPosition - 7) |> String.to_atom
            diff == 18  ->
              Integer.to_string(intcurPosition - 9) |> String.to_atom
              diff == -18  ->
                Integer.to_string(intcurPosition + 9) |> String.to_atom
            true -> :"n"
          end
        blackPositions = if(atNextPos!= :"n") do
        blackSquare = Board.getSquare(state.gameBoard, atNextPos)
        piece = Square.getPiecePid(blackSquare)

        #remove piece from square
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
            diff == -14 -> 
              atNextPos = Integer.to_string(intcurPosition + 7) |> String.to_atom
          diff == 14 -> 
                atNextPos = Integer.to_string(intcurPosition - 7) |> String.to_atom
          diff == 18  ->
            Integer.to_string(intcurPosition - 9) |> String.to_atom
            diff == -18  ->
              Integer.to_string(intcurPosition + 9) |> String.to_atom
            true -> :"n"
          end


        redPositions = if(atNextPos!= :"n") do
        redSquare = Board.getSquare(state.gameBoard, atNextPos)
        piece = Square.getPiecePid(redSquare)
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
      def converttoIntegerList(someList) do
        Enum.map(someList, fn x -> 
          {val, ""} = Atom.to_string(x)|>Integer.parse 
              val end)
      end
    end