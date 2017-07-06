import React from 'react'
import { connect } from 'react-redux'

class Game extends React.Component {
  componentWillMount() {
    const channel = this.props.channel
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

  play(card) {
    const channel = this.props.channel
      channel.push("play_card", card)
  }

  draw() {
    const channel = this.props.channel
    channel.push("draw_card")
  }

  render() {
    const current_player = this.props.current_player
    const current_card = this.props.current_card
    const cards = this.props.cards
    const history = this.props.history

    const showCards = cards.map((card, index) => (
      <li key={card.value+card.color+index}
          onClick={() => this.play(card)}
          className="list-group-item"
          style={{cursor: "pointer"}}>
        {card.value} {card.color}
      </li>
    ))

    const showHistory = history.map((play, index) => (
      <li key={index} className="list-group-item">
        <p>{play.turn} -> {play.player} plays {play.card.value} {play.card.color}</p>
      </li>
    ))

    return (
      <div>
        <h3>Player: {this.props.player}</h3>
        <p>Current Player: <b>{current_player}</b></p>
        <p>Current Card: <b>{current_card.value} {current_card.color} {current_card.next}</b></p>
        <div className="btn btn-primary" onClick={this.draw.bind(this)}><b>Draw Card</b></div>
        <ol className="list-group col-sm-4">
          {showCards}
        </ol>

        <h3>History</h3>
        <ol className="list-group">
          {showHistory}
        </ol>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {
    room: state.login.room,
    player: state.login.username,
    channel: state.login.channel,
    current_card: state.game.current_card,
    current_player: state.game.current_player,
    cards: state.game.cards,
    player_queue: state.game.player_queue,
    history: state.game.history
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
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

export default connect(mapStateToProps, mapDispatchToProps)(Game)
