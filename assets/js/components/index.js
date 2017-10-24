import React from 'react'
import { connect } from 'react-redux'

import Login from './login'
import Lobby from './lobby'
import Game from './game'

class Index extends React.Component {
  render() {
    let {status, currentPlayer} = this.props;
    switch (status) {
      case "logged":
        return <Lobby />
      case "started":
        return <Game />
      case "ended":
        return <p>GAME OVER! Player {currentPlayer} wins!</p>
      default:
        return <Login />
    }
  }
}

const mapStateToProps = (state) => {
  return {
    status: state.login.status,
    currentPlayer: state.game.current_player
  }
}

export default connect(mapStateToProps)(Index)
