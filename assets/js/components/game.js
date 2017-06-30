import React from 'react'
import socket from '../socket'

class Game extends React.Component {
  render() {
    socket.connect()

    // Now that you are connected, you can join channels with a topic:
    let channel = socket.channel("room:game", {})
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    return (
      <div>Hello react</div>
    )
  }
}

export default Game
