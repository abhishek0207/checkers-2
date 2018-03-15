defmodule CheckersWeb.Game.Piece do
    alias CheckersWeb.Game.Piece
    alias CheckersWeb.Game.Square

    defstruct [
        color: "",
        boardPosition: :none,
        nextMoves: [],
        isKing: false
    ]
    
    def start_link() do
        Agent.start_link(fn-> %Piece{} end)
    end

    def getPosition(pid) do
        Agent.get(pid, fn state -> state.boardPosition end)
    end

    def setPosition(pid, squarePid) do
        Agent.get(pid, fn state -> Map.put(state, :position, squarePid ) end)
    end

    def getNextMoves(pid) do
        Agent.get(pid, fn state -> state.nextMoves end)
    end

    def king?(pid) do
        Agent.get(pid, fn state -> state.isKing end)
    end

    def addtoSquare(pid, squarePid) do
        Square.setPiecePid(squarePid, pid)
        setPosition(pid, squarePid)
    end
    #def setColor(pid, color)  do
     #   Agent.update(pid, fn state -> Map.put(state, :color, color) end)
    #end
   
end