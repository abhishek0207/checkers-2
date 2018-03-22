defmodule CheckersWeb.Game.CheckersSet do
    alias CheckersWeb.Game.CheckersSet
    alias CheckersWeb.Game.Piece
    defstruct [
        red: [],
        black: []
    ]
    def start_link() do
        Agent.start_link(fn -> %CheckersSet{} end)
    end
    
    def addRedPid(pid, redList) do
        Agent.update(pid, fn state -> Map.put(state, :red, redList) end )
    end
    def getRedPid(pid) do
        Agent.get(pid, fn state -> state.red end )
    end
    def getBlackPid(pid) do
        Agent.get(pid, fn state -> state.black end )
    end
    def addBlackPid(pid, blackList) do
        Agent.update(pid, fn state -> Map.put(state, :Black, blackList) end)
    end
end