defmodule CheckersWeb.Game.Square do
    alias CheckersWeb.Game.Square
    alias CheckersWeb.Game.Piece
    defstruct [
        checker?: false,
        piecePid: :none
    ]
    def start_link() do
        Agent.start_link(fn-> %Square{} end)
    end
    def hasChecker?(pid) do
        Agent.get(pid, fn state -> state.checker? end)
    end
    def setChecker(pid, value) do
        Agent.update(pid, fn state -> Map.put(state, :checker?, value) end)
    end
    def setPiecePid(pid, piecePid) do
        Piece.setPosition(piecePid, pid)
        Agent.update(pid, fn state -> Map.put(state, :piecePid, piecePid) end)
        Agent.update(pid, fn state -> Map.put(state, :checker?, true) end)
    end
    def getPiecePid(pid) do
        Agent.get(pid, fn state -> state.piecePid end)
    end
    def removePiece(pid) do
        Agent.update(pid, fn state -> Map.put(state, :piecePid, :none) end)
        Agent.update(pid, fn state -> Map.put(state, :checker?, false) end)
    end
    def toString(pid) do
        "%{hasChecker => #{hasChecker?(pid)} } "
    end
end