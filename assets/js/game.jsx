import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'underscore';
import {Socket} from "phoenix";
import {MainApp} from './mainApp';
import { PlayerList } from './components';
const socket = new Socket("/socket", {});
socket.connect();


class Game extends React.Component {
  constructor(props) {
    super(props)
    this.channel = this.props.channel
    this.player = this.props.player
    this.state = {
      isGameStarted: false,
      channel: null,
      player1Joined: null,
      player2Joined: null,
      allPositions:[],
      blackPositions:[],
      currentChecker: {
      checkerColor:"",
      possiblemoves:[],
      selectedchecker:0
      },
      next : "",
      redPositions:[]
    }
  }


componentDidMount() {
  this.setState({channel:this.props.channel})
  this.setState({player: this.props.player})
  this.setState({player1Joined: true})
  console.log("entered player 1")
  this.join(this.props.channel)
  this.newGame(this.props.channel, this.props.player)
}
    join(channel) {
      channel.join()
        .receive("ok", response => {
           console.log("Joined successfully!");
         })
        .receive("error", response => {
           console.log("Unable to join");
         })
    }
  gotView(view) {
    this.setState({
      redPositions: view.red,
      player: view.player,
      isGameStarted: view.gameStarted
    })
  }

    newGame(channel, player) {
      channel.push("new_game", {playerName: player})
        .receive("ok", response => {
           console.log("New Game!");
         })
        .receive("error", response => {
           console.log("Unable to start a new game.");
         })
        }
  addPlayer(channel, player) {
    channel.push("add_player", player)
    .receive("ok", response => {
       console.log("Player added!");
     })
    .receive("error", response => {
        console.log("Unable to add new player: " + player, response);
      })
  }

  render() {
    return (
      <div>
      <MainApp channel = {this.props.channel}  player = {this.props.player} />
      </div>
    )
  }
}
function Button(props) {
    return (
      <div className="button" id={props.id} onClick={props.onClick}>
        {props.value}
      </div>
    )
  }

export default function game_start(root, channel, player) {
  ReactDOM.render(
    <Game channel={channel} player = {player}/>,
   root
  );
}