import { combineReducers } from "redux"
import LoginReducer from './login_reducer'
import GameReducer from './game_reducer'

const rootReducer = combineReducers({
  login: LoginReducer,
  game: GameReducer
})

export default rootReducer
