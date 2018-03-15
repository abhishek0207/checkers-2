defmodule Checkers.GameLogic do
    def initialState() do
       
        redPoses =  [2,4,6,8,9,11,13,15,18,20,22,24]
        blackPoses = [41,43,45,47,50,52,54,56,57,59,61,63]
        newPositions = [] 
        count = 0
        newArray = []
        newArray = for x <- 1..64 do
        cond do
                Enum.member?(redPoses, x) ->
                   newPositions = newPositions ++ "r"
                Enum.member?(blackPoses, x) ->
                     newPositions = newPositions ++ "b"
                true -> 
                   newPositions = newPositions ++ "-"
                end
        end
         %{
            redPositions: redPoses,
            blackPositions: blackPoses,
            allPositions: newArray,
         currentChecker: %{
            selectedChecker: 0,
            possiblemoves: [],
            checkerColor: "red"
         },
         next: "black"
        }
    end
    
    def redClick(state, column_position) do
        IO.puts("entered in red")
       curState = state
       count = 0
       allPos = []
       redList = Map.get(state, "redPositions")
       all = Map.get(state, "allPositions")
       redList = Enum.map(redList, fn(x) -> 
        if(x==Map.get(state, "currentChecker")|> Map.get("selectedchecker")) do
            column_position
        else
            x
        end
    end)
        #logic for crossing movement
        selected = Map.get(state, "currentChecker")|> Map.get("selectedchecker")
        diff = abs(selected - column_position)
        IO.puts("diff is #{diff}")
        blackPositions = Map.get(state, "blackPositions")
        blackPositions = cond do
            diff == 14 -> 
                IO.puts("enetreed 14 block")
                indexOfSelected = Enum.find_index(blackPositions, fn(x) -> x == (selected + 7) end)
                List.delete_at(blackPositions, indexOfSelected)
            diff == 18  ->
                indexOfSelected = Enum.find_index(blackPositions, fn(x) -> x == (selected + 9) end)
                List.delete_at(blackPositions, indexOfSelected)
            true       -> blackPositions
        end
        IO.puts("blackPositions are #{blackPositions}")
       all = all |> Enum.with_index|>Enum.map(fn{x,i} ->
            if(i==column_position - 1) do
                "r"
            else
                if(i == (Map.get(state, "currentChecker")|> Map.get("selectedchecker")) - 1) do
                    "-"
                else
                    x
                end
            end
        end)
    IO.puts('all is ')
    IO.inspect(all)
    IO.inspect(redList)
    IO.inspect(state)
    %{  redPositions: redList,
        blackPositions: blackPositions,
        allPositions: all,
        next: "black",
        currentChecker: %{
        selectedchecker: 0,
        possiblemoves: [],
        checkerColor: ''
        }

    }
    end
   
    def blackClick(state, column_position) do
        IO.puts("entered in black")
       curState = state
       count = 0
       allPos = []
       blackList = Map.get(state, "blackPositions")
       all = Map.get(state, "allPositions")
       blackList = Enum.map(blackList, fn(x) -> 
        if(x==Map.get(state, "currentChecker")|> Map.get("selectedchecker")) do
            column_position
        else
            x
        end
    end)
        #logic for diagnoal movement
        selected = Map.get(state, "currentChecker")|> Map.get("selectedchecker")
        diff = abs(selected - column_position)
        IO.puts("diff is #{diff}")
        redPositions = Map.get(state, "redPositions")
        redPositions = cond do
            diff == 14 -> 
                IO.puts("enetreed 14 block")
                indexOfSelected = Enum.find_index(redPositions, fn(x) -> x == (selected - 7) end)
                List.delete_at(redPositions, indexOfSelected)
            diff == 18  ->
                indexOfSelected = Enum.find_index(redPositions, fn(x) -> x == (selected - 9) end)
                List.delete_at(redPositions, indexOfSelected)
            true       -> redPositions
        end
        IO.puts("redkPositions are")
        IO.inspect(redPositions)
       all = all |> Enum.with_index|>Enum.map(fn{x,i} ->
            if(i==column_position - 1) do
                "b"
            else
                if(i == (Map.get(state, "currentChecker")|> Map.get("selectedchecker")) - 1) do
                    "-"
                else
                    x
                end
            end
        end)
    IO.puts('all is ')
    IO.inspect(all)
    IO.inspect(blackList)
    IO.inspect(state)
    %{  redPositions: redPositions,
        blackPositions: blackList,
        allPositions: all,
        next: "red",
        currentChecker: %{
        selectedchecker: 0,
        possiblemoves: [],
        checkerColor: ''
        }

    }
    end

end