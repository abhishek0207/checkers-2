import React from 'react';
import ReactDOM from 'react-dom';
import {Board,CheckerRow, CheckerCell, RedCheckers, BlackCheckers, PlayerList, Chat} from './components';
import {Button} from 'reactstrap'

export class MainApp extends React.Component {
    constructor(props) {
        super(props)
        this.channel =this.props.channel
        this.onBlackClick = this.onBlackClick.bind(this)
        this.onRedClick = this.onRedClick.bind(this)
        this.legalMove = this.legalMove.bind(this)   
        this.state =  {
            allPositions:[],
            blackPositions:[],
            currentChecker: {
            checkerColor:"",
            possiblemoves:[],
            selectedchecker:0
            },
            next : "",
            message: "Welcome to Checkers!! Lets wait for the other player to join...",
            redPositions: [],
            channel: this.props.channel,
            player: this.props.player,
            player1: "",
            player2: "",
            chatMessages: [],
            chat: false,
            kingList : {},
            blackKing: {},
            player1Score: 0,
            player2Score: 0, 
            gameEnded: false,
            winner: "",
            loser: ""
          }
          this.giveUp = this.giveUp.bind(this)
        
}

componentDidMount() {
    this.state.channel.on("player_added", response => {
        this.processPlayerAdded()
      })

      this.state.channel.on("player1_added", response => {
          console.log(response.message)
          console.log(response.message.red)
        this.setState({redPositions: response.message.red,
        allPositions: response.message.all,
        player1: response.message.player,
        chat: true})
      })
      this.state.channel.on("player2_added", response => {
        console.log(response.message)
        console.log(response.message.black)
        this.setState({player2: response.message.player, player1: response.message.player1})
      if(response.message.player!= this.state.player) {
      this.setState({blackPositions: response.message.black,
                    redPositions: response.message.red,
                    allPositions: response.message.all,
                    message: response.message.message,
                    chatmessages: response.message.chat,
                chat:true})
      } else {
        this.setState({blackPositions: response.message.black,
            redPositions: response.message.red,
            allPositions: response.message.all,
            chatmessages: response.message.chat,
            chat:true,
            spec: false,
            message: "Welcome to checkers " + response.message.player  + ", lets wait for " + response.message.player1 + " to play"})
      }

    })

    this.state.channel.on("new_message", response => {
        this.setState({chatMessages: response.chatmessages})
    })
    this.state.channel.on("subscribers", response => {
        console.log("These players have joined: ", response)
        })
    this.state.channel.on("moved_Red", response => {
            this.setState({blackPositions: response.message.black,
            redPositions: response.message.red,
            allPositions: response.message.all,
        next:"black",
        kingList: response.message.kings,
        player1Score: response.message.player1Score,
        player2Score: response.message.player2Score
        })
        
    if(response.message.player!= this.state.player)  {
        this.setState({message: response.message.player + "has played your turn"})
    }
    else {
        this.setState({message: response.message.player2 + "'s turn"})
    }
    if(this.state.blackPositions.length == 0 && this.state.redPositions.length > 0 ) {
        this.state.channel.push("redWon", {}).receive("ok", response => {alert("red Won the game")})
        .receive("error", response => {console.log("error")} )
    }
    
    })

    this.state.channel.on("moved_black", response => {
            this.setState({blackPositions: response.message.black,
            redPositions: response.message.red,
            allPositions: response.message.all,
        next:"red",
        blackKing: response.message.kings,
        player1Score: response.message.player1Score,
        player2Score: response.message.player2Score})
    if(response.message.player!= this.state.player)  {
        this.setState({message: response.message.player +" has played, your turn"})
    }
    else {
        this.setState({message: response.message.player1 + "'s turn"
        })
        
    }
    })

    this.state.channel.on("new_spectator", response => {
        if(response.message.gameEnded) {
            if(response.message.player == this.state.player) {
                this.setState({message: "game has ended, please join a new one"})
            }
            
        }
        else {
            this.setState({blackPositions: response.message.black,
                redPositions: response.message.red,
                allPositions: response.message.all,
                player1: response.message.player1,
                player2: response.message.player2,
                chatMessages: [],
                gameEnded: this.state.gameEnded,
                winner: this.state.winner,
                loser: this.state.loser,
                next: response.message.next
            })
            if(response.message.next =="red") {
                this.setState({message: response.message.player1 + "'s turn"})
            }
            else {
                this.setState({message: response.message.player2 + "'s turn"})
            }
        }
        
    })

    this.state.channel.on("blackWinner", response=> {
        if(response.winner == this.state.player)  {
            this.setState({message: response.loser + " has given up! You won :D",
        gameEnded: true,
        winner: response.winner,
        loser:  response.loser} )
        }
        else if(response.loser == this.state.player)  {
            this.setState({message: response.winner + " won!, you lose :(",
            gameEnded: true,
            winner: response.winner,
            loser:  response.loser})
        }
        else {
            
            this.setState({message: response.winner + " won!, " + response.loser + " lost the game",
            gameEnded: true,
            winner: response.winner,
            loser:  response.loser})
        }

    })
    this.state.channel.on("redWinner", response=> {
        if(response.winner == this.state.player)  {
            console.log(response.loser)
            this.setState({message: response.loser + " has given up! you won"})
        }
        else if(response.loser == this.state.player)  {
            console.log("in loser section")
            console.log(response.loser)
            this.setState({message: response.winner + " won!, you lose"})
        }
        else {
            
            this.setState({message: response.winner + " won!, " + response.loser + " lost the game"})
        }
    })

    //this.channel.push("show_subscribers").recieve("ok", response => {console.log("hey")})
}

componentDidUpdate() {
    
}

gotView(view) {
    console.log("entered inside")
    this.setState(view.curState)
}
processPlayerAdded() {
    this.setState({message: "Both players present.",
                    next: "red", chat:true});
}
onBlackClick(pos, king, next){
    let currentselectedChecker = this.state.currentChecker;
    currentselectedChecker.selectedchecker = pos
    currentselectedChecker.possiblemoves = next
    currentselectedChecker.checkerColor = "black"
    this.setState({
    currentChecker:currentselectedChecker
    })
}


legalMove(column_position){
    let selected = this.state.currentChecker
    let redArray = this.state.redPositions
    let blackArray = this.state.blackPositions
    if(selected) {
        let possiblemoves = selected.possiblemoves
        if(possiblemoves.includes(column_position)){
            
            if(selected.checkerColor == "red") {
                if(this.state.next=="red") {
                this.state.channel.push("moveRed", {curPosition: selected.selectedchecker, column_position: column_position, player: this.state.player, jump: false})
                    .receive("ok", response => {console.log("moved")})
                    .receive("error", response => {alert("this is not your turn")})
            }
            else{
                alert("this is not your turn")
            }

            }
            else if(selected.checkerColor == "black") {
                if(this.state.next=="black"){
                    this.state.channel.push("moveBlack", {curPosition: selected.selectedchecker, column_position: column_position, player: this.state.player})
                    .receive("ok", response => {console.log("black moved")})
                    .receive("error", response => {alert("this is not your turn")})
               }
                else{
                    alert("this is not your turn")
                }
            }
        } else {
            console.log("illegal move");
            this.setState({
                currentChecker:{
                    selectedchecker:0,
                    possiblemoves:[],
                    checkerColor:''
                }
            })

        }
    }
    
}
onRedClick(pos, king, next){
    let currentselectedChecker = this.state.currentChecker;
    currentselectedChecker.selectedchecker = pos
    currentselectedChecker.possiblemoves = next
    currentselectedChecker.checkerColor = "red"
    this.setState({
    currentChecker:currentselectedChecker
    })

}
giveUp() {
    if(confirm("are you sure? the other player will win the game")) {
        this.state.channel.push("giveUp", {Player: this.state.player})
                    .receive("ok", response => {console.log("Given up")})
                    .receive("error", response => {alert("not given up")})
    }
    
}

render(){
let chatList = this.state.chatMessages
console.log(this.state.chatMessages)
let liList = chatList.map((x) =>
            <li className="list-group-item">{x}</li>)
let chatEnabled = this.state.chat
return(
<div class="someDiv">
<div class="row">
<Stuff value = {this.state.message} />
</div>
<div class="row">
<div class="col-sm-6">
<Board red={this.state.redPositions} 
    all={this.state.allPositions} 
    black={this.state.blackPositions} 
    onBlackClick = {this.onBlackClick} 
    onRedClick = {this.onRedClick} 
    legal = {this.legalMove}
    channel = {this.state.channel}
    player = {this.state.player}
    currentChecker = {this.state.currentChecker}
    kingList = {this.state.kingList}
    blackKing = {this.state.blackKing}/>
</div>
<div class="col-sm-3">
<Score player1 = {this.state.player1} player2= {this.state.player2} red={this.state.player1Score} black = {this.state.player2Score} />
<br/>
<br/>
<Button value = "giveUp"  onClick = {this.giveUp}>Give Up!</Button>
</div>
<div class="col-sm-3">
<h3>Chat</h3>
<div id="chatArea">
            <ul className="list-group">
                   {liList}
                </ul>
                <Chat channel = {this.props.channel} player = {this.state.player} enabled = {this.state.chat} />
</div>
</div>
</div>

</div>)
}

}

function Stuff(props) {
        return(
  <h3> {props.value}</h3>
        )
}

function Score(props) {
    
    return(
       
        <div class="score">
         <center><h6>ScoreBoard</h6></center>
        <table width="100%">
            <tr width="100%">
                <td class="name" width="50%">
                    {props.player1}
                    </td>
                    <td width="50%">
        <div class="redScore circlescore">{props.red}</div> <br /> </td>
        </tr>
        <tr width="100%">
        <td class="name" width="50%">
                    {props.player2}
                    </td>
                    <td width="50%">
        <div class="blackScore circlescore">{props.black}</div>
        </td>
        </tr>
        </table>
        </div>
    )
}


