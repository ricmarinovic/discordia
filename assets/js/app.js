import "phoenix_html"

import React from "react"
import ReactDOM from "react-dom"
import { createStore } from 'redux'
import { Provider } from 'react-redux'
import {
  BrowserRouter as Router,
  Route,
  Link
} from 'react-router-dom'

import reducer from './reducers'
import Index from './components'

let store = createStore(reducer)

ReactDOM.render(
  <Provider store={store}>
    <Index />
  </Provider>
  , document.getElementById("root")
)
