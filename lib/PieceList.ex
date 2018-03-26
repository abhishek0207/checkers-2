defmodule CheckersWeb.Game.PieceList do
    alias CheckersWeb.Game.PieceList
    alias CheckersWeb.Game.Piece
    alias CheckersWeb.Game.Board
    
    def start_link() do
        Agent.start_link(fn -> [] end)
    end
    def update_list(pid, new_piece_list) do
        Agent.update(pid, fn _state -> new_piece_list end)
    end
    def createRedPositions(pid, boardpid) do
        redPoses =  [2,4,6,8,9,11,13,15,18,20,22,24]
        newList = Enum.map(redPoses, fn x -> 
            boardPosition = String.to_atom("#{x}")
            square = Board.getSquare(boardpid, boardPosition)
            {:ok, piece} = Piece.start_link()
            Piece.setColor(piece, "red")
            Piece.addtoSquare(piece, square)
            piece
        end)
       update_list(pid, newList)
    end
    def createBlackPositions(pid, boardpid) do
        blackPoses =  [41,43,45,47,50,52,54,56,57,59,61,63]
        newList = Enum.map(blackPoses, fn x -> 
            boardPosition = String.to_atom("#{x}")
            square = Board.getSquare(boardpid, boardPosition)
            {:ok, piece} = Piece.start_link()
            Piece.setColor(piece, "black")
            Piece.addtoSquare(piece, square)
            piece
        end)
       update_list(pid, newList)
    end
    def getList(pid) do
        Agent.get(pid, fn state -> state end)
    end
    def tostring(pid) do
        "[" <> pieceStrings(pid) <> "]"
    end
    def pieceStrings(pid) do
        state = Agent.get(pid, fn state -> state end)
        pieceList = Enum.map(state, fn x-> Piece.toString(x) end)
        Enum.join(pieceList, " ,")
    end
end