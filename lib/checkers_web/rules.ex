defmodule CheckersWeb.Game.Rules do
    @behaviour :gen_statem
    alias CheckersWeb.Game.Rules

    def start_link(player) do
     :gen_statem.start_link(__MODULE__, player, [])
    end
    def init(player) do
        data = %{player1: player, player2: ""}
        {:ok, :initialized, data} 
    end
    def callback_mode(), do: :state_functions

    def code_change(_vsn, state_name, state_data, _extra) do
        {:ok, state_name, state_data}
        end
    def terminate(_reason, _state, _data), do: :nothing
    
    #client function for the current state
    def show_current_state(fsm) do
        :gen_statem.call(fsm, :show_current_state)
    end
    #callback for the initial state
    def initialized({:call, from}, :show_current_state, state_data) do
        {:keep_state_and_data, {:reply, from, :initialized}}
    end
    #client function for adding a player
    def add_player(fsm, player) do
        :gen_statem.call(fsm, {:add_player, player} )
    end
    #callback for above and the name is initialized because it is for initialized state

    def initialized({:call, from}, {:add_player, player}, state_data) do
        state_data = Map.put(state_data, :player2, player)
        IO.inspect(state_data)
        {:next_state, :players_set, state_data, {:reply, from, :ok}}
    end
    #incase of invalid events
    def initialized({:call, from}, _, _state_data) do
        {:keep_state_and_data, {:reply, from, :error}}
    end
    #another state players set and we need to show the state hence below function
    
    def players_set({:call, from}, :show_current_state, _state_data) do
        {:keep_state_and_data, {:reply, from, :players_set}}
    end
    def player1_turn(fsm) do
        :gen_statem.call(fsm, :player1turn)
    end
    def player2_turn(fsm) do
        :gen_statem.call(fsm, :player2turn)
    end
    def players_set({:call, from}, :player1turn, state_data) do
        {:next_state, :player1_turn,  state_data, {:reply, from, :ok}}
    end
    def players_set({:call, from}, _, state_data) do
        {:keep_state_and_data, {:reply, from, :error}}
    end
    def player1_turn({:call, from}, :show_current_state, _state_data) do
        {:keep_state_and_data, {:reply, from, :player1_turn}}
    end
    #client function to move a checker
    def move_red(fsm, player) do
        :gen_statem.call(fsm, {:move_red, player})
    end
    def move_black(fsm, player) do
        :gen_statem.call(fsm, {:move_black, player})
    end
    def player1_turn({:call, from}, {:move_red, player}, state_data) do
        if(player == Map.get(state_data, :player1))
        do
        {:next_state, :player2_turn, state_data, {:reply, from, :ok}}
        else 
            {:keep_state_and_data, {:reply, from, :error}}
        end
    end
    def player1_turn({:call, from}, _, _state_data) do
        {:keep_state_and_data, {:reply, from, :error}}
    end
    def win(fsm) do
        :gen_statem.call(fsm, :win)
    end
    def player1_turn({:call, from}, :win, state_data) do
        {:next_state, :game_over, state_data, {:reply, from, :ok}}
    end
    def player1_turn(_event, _caller_pid, state) do
        {:reply, {:error, :action_out_of_sequence}, :player1_turn, state}
    end
    def player2_turn({:call, from}, {:move_black, player}, state_data) do
        if(player == Map.get(state_data, :player2))
        do
        {:next_state, :player1_turn, state_data, {:reply, from, :ok}}
        else 
            {:keep_state_and_data, {:reply, from, :error}}
        end
    end
    def player2_turn({:call,from}, :show_current_state, _state_data) do
        {:keep_state_and_data, {:reply, from, :player2_turn}}
    end
    def player2_turn({:call, from}, :win, state_data) do
        {:next_state, :game_over, state_data, {:reply, from, :ok}}
    end
    def player2_turn(_event, _caller_pid, state) do
        {:reply, {:error, :action_out_of_sequence}, :player2_turn, state}
    end
    def game_over({:call, from}, _, _state_data) do
        {:keep_state_and_data, {:reply, from, :error}}
    end
    def game_over({:call, from}, :show_current_state, _state_data) do
        {:keep_state_and_data, {:reply, from, :game_over}}
     end
end