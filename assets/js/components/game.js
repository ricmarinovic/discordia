import React from 'react'

export default class Game extends React.Component {
  render() {
    return (
      <div>{this.props.state}</div>
    )
  }
}
