import React from 'react';
import ReactDOM from 'react-dom';
import {Board,CheckerRow, CheckerCell, RedCheckers, BlackCheckers, PlayerList, Chat} from './components';

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
            message: "WelCome to Checkers!! Lets wait for the other player to join",
            redPositions: [],
            channel: this.props.channel,
            player: this.props.player,
            chatMessages: [],
            chat: false,
            kingList : {},
            blackKing: {}
          }
        
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
        chat: true})
      })
      this.state.channel.on("player2_added", response => {
        console.log(response.message)
        console.log(response.message.black)
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
            message: "welcome to checkers " + response.message.player  + ", lets wait for " + response.message.player1 + " to play"})
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
        kingList: response.message.kings
        })
        
    if(response.message.player!= this.state.player)  {
        this.setState({message: response.message.player + "has played your turn"})
    }
    else {
        this.setState({message: response.message.player2 + "'s turn"})
    }
    })

    this.state.channel.on("moved_black", response => {
            this.setState({blackPositions: response.message.black,
            redPositions: response.message.red,
            allPositions: response.message.all,
        next:"red",
        blackKing: response.message.kings})
    if(response.message.player!= this.state.player)  {
        this.setState({message: response.message.player +" has played, your turn"})
    }
    else {
        this.setState({message: response.message.player1 + "'s turn"
        })
        
    }
    })

    this.state.channel.on("new_spectator", response => {
        this.setState({blackPositions: response.message.black,
            redPositions: response.message.red,
            allPositions: response.message.all,
            chatMessages: []
        })
        if(this.state.next =="red") {
            this.setState({message: response.message.player1 + "'s turn"})
        }
        else {
            this.setState({message: response.message.player2 + "'s turn"})
        }
    })

    
    //this.channel.push("show_subscribers").recieve("ok", response => {console.log("hey")})
}

componentDidUpdate() {
    if(this.state.redPositions.length == 0) {
        this.state.channel.push("Redwon", {}).receive("ok", response => {console.log("red Won the game")})
        .receive("error", response => {console.log("error")} )
    }
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
render(){
let chatList = this.state.chatMessages
console.log(this.state.chatMessages)
let liList = chatList.map((x) =>
            <li className="list-group-item">{x}</li>)
let chatEnabled = this.state.chat
return(
<div class="someDiv">
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
<Stuff value = {this.state.message} />
</div>
<div class="col-sm-3">
<div className="chat">
<h3>Chat</h3>
<div id="chatArea">
            <ul className="list-group">
                   {liList}
                </ul>
                <Chat channel = {this.props.channel} player = {this.state.player} enabled = {this.state.chat} />
</div>
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


