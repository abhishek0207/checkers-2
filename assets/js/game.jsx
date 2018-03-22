import React from 'react';
import ReactDOM from 'react-dom';
import _ from 'underscore';
import {Socket} from "phoenix";
import {MainApp} from './mainApp';
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
   
    this.addPlayer1Details.bind(this)
    this.addPlayer2Details.bind(this)
  }


componentDidMount() {
  let urlParams = new URLSearchParams(window.location.search)
  let isJoined = urlParams.has('joined')
  if(!isJoined){
    this.addPlayer1Details()
  }
  else {
    
    this.addPlayer2Details()
  }

}
  addPlayer1Details() {
   this.setState({channel:this.props.channel})
   this.setState({player: this.props.player})
   this.setState({player1Joined: true})
   console.log("entered player 1")
   this.join(this.props.channel)
   this.newGame(this.props.channel, this.props.player)
  }
  addPlayer2Details() {
    console.log("entered in player2")
    this.setState({channel:this.props.channel})
    this.setState({player: this.props.player})
    this.setState({player2Joined: true})
    this.join(this.props.channel)
    this.addPlayer(this.props.channel, this.props.player)
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
 /* renderStartButtons(props) {
    return (
      <div className="btn">
        <Button value="Start the Demo Game" onClick={() => this.handleClick("start-game")} />
        <Button value="Join the Demo Game" onClick={() => this.handleClick("join-game")} />
      </div>
    )
  }

  newChannel(screen_name) {
    return socket.channel("game:player1", {screen_name: screen_name});
  }


  newGame(channel) {
    channel.push("new_game")
      .receive("ok", response => {
         this.setState({redPositions: response.red})
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

  /*handleClick(action) {
    const player1_channel = this.newChannel("player1");
    const player2_channel = this.newChannel("player2");

    if (action === "start-game") {
      this.setState({channel: player1_channel});
      this.setState({player: "player1"});
      this.join(player1_channel);
      this.newGame(player1_channel);
    } else {
      this.setState({channel: player2_channel});
      this.setState({player: "player2"});
      this.join(player2_channel);
      this.addPlayer(player2_channel, "player2");
    }
    this.setState({isGameStarted: true})
  }*/

  /*renderGame(props) {
    return (
     <MainApp channel = {this.state.channel} red = {this.state.redPositions} />
    )
  }*/

  render() {
    return (
      <div>
      <MainApp channel = {this.props.channel} red = {this.state.redPositions} player = {this.props.player} />
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