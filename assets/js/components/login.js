import React from 'react'
import { connect } from 'react-redux'

class Login extends React.Component {
  render() {
    return (
      <div className="form-group">
        <form onSubmit={this.handleSubmit.bind(this)}>
          <input type="text" placeholder="Room" className="form-control"
            onChange={this.handleChangeRoom.bind(this)}
            value={this.props.room}
          />
          <input type="text" placeholder="Username" className="form-control"
            onChange={this.handleChangeUsername.bind(this)}
            value={this.props.username}
          /><br />
          <input type="submit" className="btn btn-primary" value="Enter" />
        </form>
      </div>
    )
  }

  handleChangeRoom(event) {
    this.props.setRoom(event.target.value)
  }

  handleChangeUsername(event) {
    this.props.setUsername(event.target.value)
  }

  handleSubmit(event) {
    event.preventDefault()

    const { room, username } = this.props

    if (room && username) {
      this.props.login()
    }
  }
}

const mapStateToProps = (state) => {
  const { room, username } = state.login

  return { room, username }
}

const mapDispatchToProps = (dispatch) => {
  return {
    setRoom: (room) => dispatch({
      type: "SET_ROOM",
      payload: room,
    }),
    setUsername: (username) => dispatch({
      type: "SET_USERNAME",
      payload: username,
    }),
    login: () => dispatch({
      type: "LOGIN",
    }),
  }
}

export default connect(mapStateToProps, mapDispatchToProps)(Login)
