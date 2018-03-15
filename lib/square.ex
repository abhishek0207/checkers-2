defmodule CheckersWeb.Game.Square do
    alias CheckersWeb.Game.Square

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
    def setChecker(pid) do
        Agent.update(pid, fn state -> Map.put(state, :checker?, true) end)
    end
    def setPiecePid(pid, piecePid) do
        Agent.update(pid, fn state -> Map.put(state, :piecePid, piecePid) end)
    end
    def getPiecePid(pid) do
        Agent.update(pid, fn state -> state.piecePid end)
    end
    def toString(pid) do
        "%{hasChecker => #{hasChecker?(pid)} } "
    end
end