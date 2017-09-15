import { combineReducers } from "redux"
import LoginReducer from './LoginReducer'
import GameReducer from './GameReducer'

export default combineReducers({
  login: LoginReducer,
  game: GameReducer
})
