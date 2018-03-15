defmodule CheckersWeb.Game.PieceList do
    alias CheckersWeb.Game.PieceList
    alias CheckersWeb.Game.Piece
    
    def start_link() do
        Agent.start_link(fn -> [] end)
    end
    def update_list(pid, new_piece_list) do
        Agent.update(pid, fn _state -> new_piece_list end)
    end
end