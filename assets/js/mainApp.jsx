import React from 'react';
import ReactDOM from 'react-dom';
import {Board,CheckerRow, CheckerCell, RedCheckers, BlackCheckers} from './components';

export default function app_start(root, channel) {
    ReactDOM.render(<MainApp channel = {channel} />, root)
}
const exinitialState = {
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
  
class MainApp extends React.Component {
    constructor(props) {
        super(props)
        this.channel =this.props.channel;
        this.state = exinitialState
        this.onBlackClick = this.onBlackClick.bind(this)
        this.onRedClick = this.onRedClick.bind(this)
        this.legalMove = this.legalMove.bind(this)
        this.channel.join()
              .receive("ok" , this.gotView.bind(this) )
              .receive("error", resp => { console.log("Unable to join", resp) })

}
gotView(view) {
    console.log("entered inside")
    this.setState(view.curState)
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
                this.channel.push("moveRed", {state:this.state, column_position: column_position })
                    .receive("ok", this.gotView.bind(this))
            }
            else{
                alert("this is not your turn")
            }

            }
            else if(selected.checkerColor == "black") {
                if(this.state.next=="black"){
                    this.channel.push("moveBlack", {state:this.state, column_position: column_position })
                    .receive("ok", this.gotView.bind(this))
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