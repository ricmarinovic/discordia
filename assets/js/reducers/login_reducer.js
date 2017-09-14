const initialState = {
  room: "",
  username: "",
  presences: {},
  players: [],
  status: "not_logged"
}

export default (state = initialState, action) => {
  switch (action.type) {
    case "LOGIN":
      return Object.assign({}, state, {
        room: action.room,
        username: action.username,
        status: action.status
      })
    case "UPDATE_PLAYERS":
      return Object.assign({}, state, {
        presences: action.presences,
        players: action.players
      })
    case "GAME_STATUS":
      return Object.assign({}, state, {
        status: action.status
      })
    case "SET_CHANNEL":
      return Object.assign({}, state, {
        channel: action.channel
      })
    case "GAME_OVER":
      return Object.assign({}, initialState, {
        status: action.status
      })
    default:
      return state
  }
}
