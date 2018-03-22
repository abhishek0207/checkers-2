defmodule CheckersWeb.Game.Supervisor do
    use Supervisor
    alias CheckersWeb.Game

    def start_link, do: Supervisor.start_link(__MODULE__, :ok , name: __MODULE__)
    def init(:ok) do
        children = [
            worker(Game, [])
        ]
        Supervisor.init(children, strategy: :simple_one_for_one) #if process dies, start the another one
    end
    
    def start_game(gameName, player), do: Supervisor.start_child(__MODULE__, [gameName, player] )
    
    def stop_game(name) do
        Supervisor.terminate_child(__MODULE__, pid_from_name(name))
    end

    defp game_data({_id, pid, _type, _modules}) do
        pid
        |> GenServer.call(:get_data)
        |> Map.take([:id, :attacker, :defender, :turns, :over, :winner])
      end
    defp pid_from_name(name) do
        name
        |> Game.via_tuple()
        |> GenServer.whereis()
      end
end