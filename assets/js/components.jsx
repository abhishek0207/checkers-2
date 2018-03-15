import React from 'react';
import ReactDOM from 'react-dom';

export class Board extends React.Component {
    constructor(props) {
        super(props) 
    }

    render(){
        let rows = [];
        for (let i=1; i<=8; i++) {
            let selected = this.props.currentChecker;
            if(selected.possiblemoves.length > 0) {
            rows.push(<CheckerRow number = {i}
                all = {this.props.all}
                red={this.props.red} 
                black={this.props.black} blackmethod={this.props.onBlackClick} 
                redmethod={this.props.onRedClick}
                legal ={this.props.legal} nextMoves = {selected.possiblemoves} />)
            }
            else {
                rows.push(<CheckerRow number = {i} red={this.props.red} 
                    all = {this.props.all}
                    black={this.props.black} blackmethod={this.props.onBlackClick} 
                    redmethod={this.props.onRedClick}
                    legal ={this.props.legal} />)
            }
        }
        return(
            <div className="board">
            
            {rows}
        </div>)
    }
    
}

export class CheckerRow extends React.Component {
    constructor(props){
        super(props)
        this.movecheckers = this.movecheckers.bind(this)
    }
    movecheckers(column_id)
    {
        
        let moveTolegal = this.props.legal
        moveTolegal(column_id)
    }
    render() {
        let row = [];
        let checker_column_number = 0;
        for(let i =1;i<=8;i++) {
            checker_column_number=(this.props.number-1) * 8 + i
            let highlight = ""
            
            if(this.props.red.includes(checker_column_number)) {
                row.push(<CheckerCell number = {checker_column_number} 
                    all = {this.props.all}
                    red={this.props.red} redmethod = {this.props.redmethod} />)
            }
            else if(this.props.black.includes(checker_column_number)){
                row.push(<CheckerCell number = {checker_column_number} 
                    all = {this.props.all}
                    black={this.props.black} blackmethod={this.props.blackmethod} />)
            }
            else {
                if(this.props.nextMoves) {
                    if(this.props.nextMoves.includes(checker_column_number)){
                    row.push(<CheckerCell highlight={true} number = {checker_column_number}
                        all = {this.props.all} 
                        onClick={() => this.movecheckers((this.props.number-1) * 8 + i)} />)
                    }
                    else {
                        row.push(<CheckerCell number = {checker_column_number} 
                            all = {this.props.all}
                            onClick={() => this.movecheckers((this.props.number-1) * 8 + i)} />)
                    }
                }
                else {
                    row.push(<CheckerCell number = {checker_column_number} 
                        all = {this.props.all}
                        onClick={() => this.movecheckers((this.props.number-1) * 8 + i)} />)
                }
                
            }
            
            
        }

        return (
            <div className="checker_row"> {row} </div>
        )
    }
}

export class CheckerCell extends React.Component {

    render() {
        let rownumber= Math.ceil(this.props.number/8);
        let className = "checker_cell"
        let pieces = <div></div>
        if(this.props.highlight) {
            className+= " highlight"
        }
        if(rownumber%2 == 0) {
            
            className+= " even"
        }
        else {
            className+=" odd"
        }
        

        if(this.props.red) {
            if(this.props.red.includes(this.props.number))
            pieces = <RedCheckers all = {this.props.all}bPosition = {this.props.number} play={this.props.play} redmethod={this.props.redmethod} hasChecker = {true} checkerType="red"/>
        }
        if(this.props.black){
            if(this.props.black.includes(this.props.number))
            pieces = <BlackCheckers all={this.props.all} bPosition = {this.props.number} blackmethod={this.props.blackmethod} hasChecker={false} checkerType="black"/>
        }
        return (
            
            <div className={className} hasChecker={false} onClick={this.props.onClick} checkerType="">{pieces}</div>
        )
    }
}

export class RedCheckers extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            position: this.props.bPosition,
            king: false,
            nextPositions:[]
        }
        this.handleClick = this.handleClick.bind(this)
    }
    handleClick(){
        let redmethod = this.props.redmethod
        let newPositions = this.state.nextPositions
        let currentPosition =this.state.position;
        let newRight = currentPosition + 7
        let newLeft = currentPosition + 9
        let allPositions = this.props.all
        if(allPositions[newLeft - 1] =="b")
            {
                let cuttingMove = newLeft + 9
                if(allPositions[cuttingMove - 1] == "-")
                    {
                        newPositions.push(cuttingMove)
                    }
                
            }
           
            if(allPositions[newRight - 1] =="b")
            {
                
                let cuttingMove = newRight + 7
                
                if(allPositions[cuttingMove - 1] == "-")
                    {
                       
                        newPositions.push(cuttingMove)
                    }
                
            }
           
        redmethod(this.state.position, this.state.king, this.state.nextPositions)
    }

    componentDidMount(){
        let currentPosition =this.state.position;
        let newLeft = currentPosition + 7
        let newRight = currentPosition + 9

        let newPositions = [];
        if(newLeft%8==0){
            newLeft = 0;
        }
        if(newRight%8==0){
            newRight = 0;
        }
        newPositions.push(newLeft)
        newPositions.push(newRight)
        this.setState({nextPositions: newPositions})
    }

    render() {
        return(
        <div className="RedCheckers circle" onClick={this.handleClick}>
        </div>)
    }

}

export class BlackCheckers extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            position: this.props.bPosition,
            king: false,
            nextPositions:[]
        }
        this.handleClick = this.handleClick.bind(this)
    }
    componentDidMount(){
        let currentPosition =this.state.position;
        let newRight = currentPosition - 7
        let newLeft = currentPosition - 9
        let newPositions = [];
        let allPositions = this.props.all
        
                if(Math.abs(currentPosition - newLeft) <=6 ){
                    newLeft = 0;
                }
                newPositions.push(newLeft)
                if(Math.abs(currentPosition - newRight >= 9)){
                    newRight = 0;
                }
                newPositions.push(newRight)
        this.setState({nextPositions: newPositions})
    }
    handleClick() {
        let blackmethod = this.props.blackmethod
        let allPositions = this.props.all
        let newPositions = this.state.nextPositions
        let currentPosition =this.state.position;
        let newRight = currentPosition - 7
        let newLeft = currentPosition - 9
        if(allPositions[newLeft - 1] =="r")
            {
                let cuttingMove = newLeft - 9
                if(allPositions[cuttingMove - 1] == "-")
                    {
                        newPositions.push(cuttingMove)
                    }
                
            }
           
            if(allPositions[newRight - 1] =="r")
            {
                let cuttingMove = newRight - 7
                if(allPositions[cuttingMove - 1] == "-")
                    {
                       
                        newPositions.push(cuttingMove)
                    }
                
            }
           
        blackmethod(this.state.position, this.state.king, newPositions)
    }
    render() {
        return(
        <div className="BlackCheckers circle" onClick = {this.handleClick}>
       
        </div>)
    }

}