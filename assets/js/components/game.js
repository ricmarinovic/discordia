import React from 'react'
import { connect } from 'react-redux'

class Game extends React.Component {
  componentWillMount() {
    const channel = this.props.channel
    channel.push("player_info")
      .receive("ok", (payload) => {
        this.props.playerInfo(payload)
      })
  }

  play(card) {
    const channel = this.props.channel

    channel.push("play_card", card)
      .receive("ok", (payload) => {
        this.props.playerInfo(payload)
      })

    console.log(card)
  }

  render() {
    this.props.channel.on("game_info", (payload) => {
      this.props.gameInfo(payload)
    })

    const current_player = this.props.current_player
    const current_card = this.props.current_card
    const cards = this.props.cards

    const showCards = cards.map((card, index) => (
      <li key={card.value+card.color+index}
          onClick={() => this.play(card)}
          className="list-group-item">
        {card.value} {card.color}
      </li>
    ))

    return (
      <div>
        <h1>Room: {this.props.room}</h1>
        <h3>Player: {this.props.player}</h3>
        <p>Current Player: {current_player}</p>
        <p>Current Card: {current_card.value} {current_card.color}</p>
        <p>Your cards:</p>
        <ul className="list-group col-sm-4">
          {showCards}
        </ul>
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
    cards: state.game.cards
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    gameInfo: (payload) => dispatch({
      type: "GAME_INFO",
      current_card: payload.current_card,
      current_player: payload.current_player
    }),
    playerInfo: (payload) => dispatch({
      type: "PLAYER_INFO",
      cards: payload.cards
    })
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Game)
