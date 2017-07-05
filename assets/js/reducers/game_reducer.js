const initialState = {
  current_card: {},
  current_player: "",
  cards: [],
  player_queue: [],
  history: []
}
export default (state = initialState, action) => {
  switch (action.type) {
    case "GAME_INFO":
      return Object.assign({}, state, {
        current_card: action.current_card,
        current_player: action.current_player,
        player_queue: action.player_queue,
        history: action.history
      })
    case "PLAYER_INFO":
      return Object.assign({}, state, {
        cards: action.cards
      })
    default:
      return state
  }
}
