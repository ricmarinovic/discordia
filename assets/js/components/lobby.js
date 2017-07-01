import React from 'react'
import { Link } from 'react-router-dom'
import { Socket, Presence } from "phoenix"

export default class Lobby extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      players: [],
      presences: {},
      room: this.props.room,
      username: this.props.username
    }
  }

  componentWillMount() {
    let socket = new Socket("/socket", {
      params: {username: this.state.username}
    })
    socket.connect()

    this.channel = socket.channel("room:" + this.state.room, {
      username: this.state.username
    })
    this.channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    this.channel.on("presence_state", (state) => {
      const presences = Presence.syncState(this.state.presences, state)
      this.updatePlayers(presences)
    })
    this.channel.on("presence_diff", (diff) => {
      const presences = Presence.syncDiff(this.state.presences, diff)
      this.updatePlayers(presences)
    })
  }

  listBy(username, {metas: metas}) {
    return {
      username: username
    }
  }

  updatePlayers(presences) {
    const players = Presence.list(presences, this.listBy)
      .map((presence) => { return presence.username })

      this.setState({
      players: players,
      presences: presences,
      room: this.state.room,
      username: this.state.username
    })
  }

  startGame(event) {
    event.preventDefault()

  }

  render() {
    return (
      <div>
        Room: {this.state.room} <br />
        Username: {this.state.username} <br />
        Players: {this.state.players.map((player) =>
          <li key={player}>{player}</li>)}
      </div>
    )
  }
}
