import React from 'react'
import { connect } from 'react-redux'

class Lobby extends React.Component {
  render() {
    return (
      <div>
        <p>Room: {this.props.room}</p>
        <p>Username: {this.props.username}</p>
        <ul className="list-group col-sm-4">
          {this.props.players.map((player) => <li key={player} className="list-group-item">{player}</li>)}
        </ul>
        <p><input type="submit" className="btn btn-primary" value="Start game" onClick={this.startGame.bind(this)} /></p>
      </div>
    )
  }

  startGame(event) {
    event.preventDefault()
  }
}

const mapStateToProps = (state) => {
  return {
    room: state.login.room,
    username: state.login.username,
  }
}

const mapDispatchToProps = (dispatch) => {
  return { }
}

export default connect(mapStateToProps, mapDispatchToProps)(Lobby)
