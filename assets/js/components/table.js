import React from 'react'
import { connect } from 'react-redux'
import { Socket } from "phoenix"

class Table extends React.Component {
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

    channel.on("game_info", (game_info) => {
      this.props.gameInfo(game_info)
      channel.push("player_info")
        .receive("ok", (player_info) => {
          this.props.playerInfo(player_info)
        })
    })
    channel.on("game_over", (winner) => {
      this.props.gameOver(winner)
    })
  }

  render() {
    const { current_player, current_card } = this.props

    return (
      <div>
        <ul>
          <li>Current player: { current_player }</li>
          <li>Current card: {current_card.value} { current_card.color }</li>
        </ul>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    room: state.login.room,
    channel: state.login.channel,
    current_card: state.game.current_card,
    current_player: state.game.current_player,
    player_queue: state.game.player_queue,
    history: state.game.history
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    setChannel: (channel) => dispatch({
      type: "SET_CHANNEL",
      channel: channel
    }),
    gameInfo: (payload) => dispatch({
      type: "GAME_INFO",
      current_card: payload.current_card,
      current_player: payload.current_player,
      player_queue: payload.player_queue,
      history: payload.history
    }),
    playerInfo: (payload) => dispatch({
      type: "PLAYER_INFO",
      cards: payload.cards
    }),
    gameOver: () => dispatch({
      type: "GAME_OVER",
      status: "ended"
    })
  }
}


export default connect(mapStateToProps, mapDispatchToProps)(Table)
