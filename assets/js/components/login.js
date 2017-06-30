import React from 'react'
import { Redirect } from 'react-router'

import Game from './game'

export default class Login extends React.Component {
  constructor(props) {
    super(props)

    this.state = {
      room: '',
      username: '',
      hasLogin: false
    }

    this.handleSubmit = this.handleSubmit.bind(this);
  }

  handleSubmit(event) {
    event.preventDefault()
    this.setState({hasLogin: true})
  }

  render() {
    return (
      <div className="form-group">
        <form onSubmit={this.handleSubmit}>
          <input type="text" placeholder="Room" className="form-control" name="room" />
          <input type="text" placeholder="Username" className="form-control" name="username" />
          <input type="submit" value="Enter" className="btn btn-primary" />
        </form>

        {this.state.hasLogin ? (
          <Redirect to="/game" />
        ) : null
        }
      </div>
    )
  }
}
