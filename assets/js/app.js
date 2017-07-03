import "phoenix_html"

import React from 'react'
import ReactDOM from 'react-dom'
import { createStore } from 'redux'
import { Provider } from 'react-redux'

import rootReducer from './reducers'
import Index from './components/index'

let store = createStore(rootReducer)

ReactDOM.render(
  <Provider store={store}>
    <Index />
  </Provider>
  , document.getElementById('root')
)
