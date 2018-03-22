import React from 'react';
import ReactDOM from 'react-dom';
import {Board,CheckerRow, CheckerCell, RedCheckers, BlackCheckers} from './components';

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
            message: "one Player playing",
            redPositions: [],
            channel: this.props.channel,
            player: this.props.player
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
        allPositions: response.message.all })
      })
      this.state.channel.on("player2_added", response => {
        console.log(response.message)
        console.log(response.message.black)
      this.setState({blackPositions: response.message.black,
                    redPositions: response.message.red,
                    allPositions: response.message.all})
    })

    this.state.channel.on("moved_Red", response => {
        console.log("enterede moved Red")
            this.setState({blackPositions: response.message.black,
            redPositions: response.message.red,
            allPositions: response.message.all,
        next:"black",
    message: "player 1 has played"})
    })

    this.state.channel.on("moved_black", response => {
        console.log("enterede moved black")
        console.log(response.message.black)
            this.setState({blackPositions: response.message.black,
            redPositions: response.message.red,
            allPositions: response.message.all,
        next:"red",
    message: "player 2 has played"})
    })
}

gotView(view) {
    console.log("entered inside")
    this.setState(view.curState)
}
processPlayerAdded() {
    this.setState({message: "Both players present.",
                    next: "red"});
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
                this.state.channel.push("moveRed", {curPosition: selected.selectedchecker, column_position: column_position, player: this.state.player})
                    .receive("ok", response => {console.log("moved")})
            }
            else{
                alert("this is not your turn")
            }

            }
            else if(selected.checkerColor == "black") {
                if(this.state.next=="black"){
                    this.state.channel.push("moveBlack", {curPosition: selected.selectedchecker, column_position: column_position, player: this.state.player})
                    .receive("ok", response => {console.log("black moved")})
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
return(<Board red={this.state.redPositions} 
    all={this.state.allPositions} 
    black={this.state.blackPositions} 
    onBlackClick = {this.onBlackClick} 
    onRedClick = {this.onRedClick} 
    legal = {this.legalMove}
    currentChecker = {this.state.currentChecker}/>)
}
}
