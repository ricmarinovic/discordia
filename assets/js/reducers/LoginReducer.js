const initial = {
  room: '',
  username: '',
  status: '',
}

export default (state = initial, action) => {
  switch (action.type) {
    case "SET_ROOM":
      return { ...state, room: action.payload }
    case "SET_USERNAME":
      return { ...state, username: action.payload }
    case "LOGIN":
      return { ...state, status: 'logged' }
    default:
      return state
  }
}
