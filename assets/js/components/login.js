import React from 'react'
import { Redirect } from 'react-router'

import Lobby from './lobby'

export default class Login extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      room: '',
      username: '',
      logged: false
    }

    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleSubmit(event) {
    event.preventDefault()
    this.setState({
      room: this.refs.room.value,
      username: this.refs.username.value,
      logged: true
    })
  }

  render() {
    if (this.state.logged) {
      window.userToken = this.state.username
      return (
        <Lobby
          room={this.state.room}
          username={this.state.username}
        />
      )
    }

    return (
      <div className="form-group">
        <form onSubmit={this.handleSubmit}>
          <input type="text" placeholder="Room" className="form-control" name="room" ref="room" />
          <input type="text" placeholder="Username" className="form-control" name="username" ref="username" />
          <input type="submit" value="Enter" className="btn btn-primary" />
        </form>
      </div>
    )
  }
}
