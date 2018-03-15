defmodule CheckersWeb.Game.Player do
    alias CheckersWeb.Game.Player
    alias CheckersWeb.Board
    alias Checkers.Piece
    alias CheckersWeb.Game

    defstruct [
        id: :none,
        name: :none,
        colorSet: :none,
    ]
    def create() do
        {:ok, colorSet} = CheckerSet.start_link()
        Agent.start_link(fn -> %Player{id: :none, name: :none, colorSet: colorSet} end)   
    end
    def playerName(pid) do
        Agent.get(pid, fn state -> state.name end)
    end
    def setName(pid, name) do
       # Agent.Update(pid, fn state-> Map.put(state, :name, name) end)
    end
    def playerPositions(pid) do
        Agent.get(pid, fn state -> state.positions end)
    end

end