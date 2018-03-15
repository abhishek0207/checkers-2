defmodule CheckersWeb.Game.Board do
    alias CheckersWeb.Game.Square
    def create() do
        Agent.start_link(fn -> initializeBoard() end) 
    end
    defp boardValues() do
        for x <- 1..64 do
            String.to_atom("#{x}")
        end
    end
    defp initializeBoard() do
        Enum.reduce(boardValues(), %{}, fn(key, board) ->
            {:ok, square} = Square.start_link()
            Map.put(board, key, square)
            end )
    end
    def getSquare(boardPid, key) when is_atom key do
        Agent.get(boardPid, fn board -> board[key] end)
    end
    def toString(board) do
        IO.inspect(board)
        "%{" <> string_body(board) <> "}"
    end
    def string_body(board) do
        Enum.reduce(boardValues(), "", fn(key, acc)->
            square = getSquare(board, key)
            acc <> "#{key} => #{Square.toString(square)}, \n"
            end )
    end
end