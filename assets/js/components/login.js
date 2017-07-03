import React from 'react'
import { connect } from 'react-redux'

class Login extends React.Component {
  handleSubmit(event) {
    event.preventDefault()

    const room = this.refs.room.value
    const username = this.refs.username.value

    this.props.login(room, username)
  }

  render() {
    return (
      <div className="form-group">
        <form onSubmit={this.handleSubmit.bind(this) }>
          <input type="text" placeholder="Room" className="form-control" name="room" ref="room" />
          <input type="text" placeholder="Username" className="form-control" name="username" ref="username" /><br />
          <input type="submit" className="btn btn-primary" value="Enter" />
        </form>
      </div>
    )
  }
}

const mapStateToProps = (state) => {
  return {}
}

const mapDispatchToProps = (dispatch) => {
  return {
    login: (room, username) => dispatch({
      type: "LOGIN",
      room: room,
      username: username,
      status: "logged"
    })
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Login)
