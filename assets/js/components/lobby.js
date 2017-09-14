import React from 'react'
import { connect } from 'react-redux'
import { Socket, Presence } from "phoenix"
import Table from './table'

class Lobby extends React.Component {
  componentWillMount() {
    let socket = new Socket("/socket", {
      params: { username: this.props.username }
    })
    socket.connect()

    const channel = socket.channel("room:" + this.props.room, {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })
    this.props.setChannel(channel)

    channel.on("presence_state", (state) => {
      const presences = Presence.syncState(this.props.presences, state)
      this.updatePlayers(presences)
    })
    channel.on("presence_diff", (diff) => {
      const presences = Presence.syncDiff(this.props.presences, diff)
      this.updatePlayers(presences)
    })

    channel.on("game_started", () => this.props.gameStarted())
    channel.on("game_stopped", () => this.props.gameStopped())
  }

  updatePlayers(presences) {
    const players = Presence.list(presences, (username, { metas: metas }) => {
      return { username } }).map((presence) => presence.username )
    this.props.updatePlayers(presences, players)
  }

  startGame(event) {
    event.preventDefault()
    const channel = this.props.channel
    channel.push("start_game", {players: this.props.players})
      .receive("ok", () => { this.props.gameStarted() })
      .receive("error", (reason) => {
        console.log(reason)
      })
  }

  render() {
    return (
      <div>
        <p>Room:{this.props.room}</p>
        <p>Username: {this.props.username}</p>
        <ul className="list-group col-sm-4">
          {this.props.players.map((player) => <li key={player} className="list-group-item">{player}</li>)}
        </ul>
        <input type="submit" className="btn btn-primary" value="Start game" onClick={this.startGame.bind(this)} />
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    room: state.login.room,
    username: state.login.username,
    presences: state.login.presences,
    players: state.login.players,
    channel: state.login.channel
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    updatePlayers: (presences, players) => dispatch({
      type: "UPDATE_PLAYERS",
      presences: presences,
      players: players
    }),
    gameStarted: () => dispatch({
      type: "GAME_STATUS",
      status: "started",
    }),
    gameStopped: () => dispatch({
      type: "GAME_STATUS",
      status: "stopped"
    }),
    setChannel: (channel) => dispatch({
      type: "SET_CHANNEL",
      channel: channel
    })
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Lobby)
