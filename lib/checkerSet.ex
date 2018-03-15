defmodule CheckersWeb.Game.CheckersSet do
    alias CheckersWeb.Game.CheckersSet
    alias CheckersWeb.Game.Piece
    defstruct [
        red: :none,
        black: :none
    ]
    def start_link() do
        Agent.start_link(fn -> initializeSet() end)
    end
    def initializeSet() do
        Enum.reduce(keys(), %CheckersSet{}, fn key, set ->
        {:ok, island} = Piece.start_link
        Map.put(set, key, island)
            end)
    end
    
    def keys() do
       %CheckersSet{} |> Map.from_struct |> Map.keys
    end
end