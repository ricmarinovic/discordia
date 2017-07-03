const initialState = {
  current_card: {},
  current_player: "",
  cards: []
}
export default (state = initialState, action) => {
  switch (action.type) {
    case "GAME_INFO":
      return Object.assign({}, state, {
        current_card: action.current_card,
        current_player: action.current_player
      })
    case "PLAYER_INFO":
      return Object.assign({}, state, {
        cards: action.cards
      })
    default:
      return state
  }
}
