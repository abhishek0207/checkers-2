defmodule CheckersWeb.Game.Presence do
    use Phoenix.Presence, otp_app: :checkers,
                          pubsub_server: Checkers.PubSub

end