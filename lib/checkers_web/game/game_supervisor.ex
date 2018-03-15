defmodule CheckersWeb.Game.Supervisor do
    use Supervisor
    alias CheckersWeb.{Game}

    def start_link, do: Supervisor.start_link(__MODULE__, :ok , name: __MODULE__)
    def init(:ok) do
        children = [
            worker(Game, [], restart: :temporary)
        ]
        supervise(children, strategy: :simple_one_for_one) #if process dies, start the another one
    end

    def create_game(id), do: Supervisor.start_child(__MODULE__, [id] )
    def current_games do 
        __MODULE__ |> Supervisor.which_children|>Enum.map(&game_data/1)
    end

    defp game_data({_id, pid, _type, _modules}) do
        pid
        |> GenServer.call(:get_data)
        |> Map.take([:id, :attacker, :defender, :turns, :over, :winner])
      end
end