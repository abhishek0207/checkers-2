defmodule CheckersWeb.Game.Player do
    alias CheckersWeb.Game.Player
    alias CheckersWeb.Board
    alias Checkers.Piece
    alias CheckersWeb.Game.CheckersSet
    alias CheckersWeb.Game.PieceList

    defstruct [
        id: :none,
        name: :none,
        colorSet: :none,
        board: :none
    ]
    def create(name, boardPid) do
        {:ok, colorSet} = CheckersSet.start_link()
        Agent.start_link(fn -> %Player{id: :none, name: name, colorSet: colorSet, board: boardPid } end)   
    end
    def create(boardPid) do
        {:ok, colorSet} = CheckersSet.start_link()
        Agent.start_link(fn -> %Player{id: :none, name: :none, colorSet: colorSet, board: boardPid} end)   
    end
    def playerName(pid) do
        Agent.get(pid, fn state -> state.name end)
    end
    def getColorSet(pid) do
        Agent.get(pid, fn state -> state.colorSet end)
    end
    def setName(pid, name) do
        Agent.update(pid, fn state-> Map.put(state, :name, name) end)
    end
    
    def playerPositions(pid) do
        Agent.get(pid, fn state -> state.positions end)
    end
    
    def setPieces(pid, board, color) do
        {:ok, colorSet} = PieceList.start_link()
        if(color == "red") do
            newList = PieceList.createRedPositions(colorSet, board)
        else
            newList = PieceList.createBlackPositions(colorSet, board)
        end
        Agent.update(pid, fn state -> Map.put(state, :colorSet, colorSet) end)
    end
    def tostring(pid) do
        "%{name => #{playerName(pid)} } "
    end

end