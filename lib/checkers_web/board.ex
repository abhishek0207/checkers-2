defmodule CheckersWeb.Game.Board do
    alias CheckersWeb.Game.Square
    alias CheckersWeb.Game.Piece
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

    def getBoardPosition(boardPid, squarepid) do
        board = Agent.get(boardPid, fn state -> state end)
        Enum.find(board, fn{key, val} -> val == squarepid end)
        |> elem(0)
    end
    def toString(board) do
        IO.inspect(board)
        "%{" <> string_body(board) <> "}"
    end
    def string_body(board) do
        Enum.reduce(boardValues(), "", fn(key, acc)->
            square = getSquare(board, key)
            if(Square.hasChecker?(square)) do
                piece = Square.getPiecePid(square)
                acc <> "#{key} => #{Square.toString(square)}, Piece => #{Piece.toString(piece)} \n"
            else
                acc <> "#{key} => #{Square.toString(square)}, Piece => empty \n"
            end
            end )
    end
    def getAllPositions(board) do
        Enum.map(boardValues(), fn(key) ->
            square = getSquare(board, key)
            if(Square.hasChecker?(square)) do
                piece = Square.getPiecePid(square)
                color = Piece.getColor(piece)
                if(color == "red") do
                    "r"
             else
                "b"
            end
        else
            "-"
        end
    end)
end
end